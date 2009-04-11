# -*- coding: utf-8 -*-

# Pioneers - web game based on the Settlers of Catan board game.
#
# Copyright (C) 2009 Jakub Kuźma <qoobaa@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class Game < ActiveRecord::Base
  has_many :players, :order => "number"
  has_many :dice_rolls, :order => "turn DESC"
  has_many :discards
  has_many :offers
  has_many :cards
  has_many :exchanges
  has_many :robberies
  has_one :board

  belongs_to :largest_army_player, :class_name => "Player"
  belongs_to :longest_road_player, :class_name => "Player"

  delegate :id, :to => :current_player, :prefix => true
  delegate :hexes, :nodes, :edges, :height, :width, :size, :hexes_groupped, :edges_groupped, :nodes_groupped, :robber_position, :to => :board, :prefix => true
  delegate :robber?, :value, :to => :current_dice_roll, :prefix => true
  delegate :resources, :to => :current_discard_player, :prefix => true

  after_update :save_players, :sum_cards_count, :end_game

  state_machine :initial => :preparing do
    event :start_game do
      transition :preparing => :playing
    end

    event :end_game do
      transition :playing => :ended, :if => :winner?
    end

    state :playing do
      validates_length_of :players, :in => 2..4
      validates_presence_of :board
      validate :players_ready
    end

    before_transition :on => :start_game do |game|
      game.reset_robber
      game.reset_current_turn_card_played
      game.deal_resources
      game.largest_army_size = 2
      game.longest_road_length = 4
      game.current_turn = 1
      game.current_player_number = 1
      game.army_cards = 14
      game.monopoly_cards = 2
      game.year_of_plenty_cards = 2
      game.road_building_cards = 2
      game.victory_point_cards = 5
    end
  end

  state_machine :phase, :initial => :first_settlement do

    # settlement built

    event :settlement_built do
      transition :first_settlement => :first_road
      transition :second_settlement => :second_road
      transition :after_roll => :after_roll # dummy
    end

    before_transition :on => :settlement_built do |game, transition|
      game.playing? and game.current_user_turn?(*transition.args)
    end

    before_transition :on => :settlement_built, :do => :longest_road

    # road built

    event :road_built do
      transition :first_road => :first_settlement, :if => :next_player?
      transition :first_road => :second_settlement
      transition :second_road => :second_settlement, :if => :previous_player?
      transition :second_road => :before_roll
      transition :road_building_first_road => :road_building_second_road
      transition :road_building_second_road => :after_roll
      transition :after_roll => :after_roll # dummy
    end

    before_transition :on => :road_built do |game, transition|
      game.playing? and game.current_user_turn?(*transition.args)
    end

    before_transition :on => :road_built, :do => :longest_road
    before_transition :first_road => :first_settlement, :do => :next_player
    before_transition :second_road => :second_settlement, :do => :previous_player

    # dice rolled

    event :dice_rolled do
      transition :before_roll => :discard, :if => lambda { |game| game.current_dice_roll_robber? and game.next_player_to_discard? }
      transition :before_roll => :robber, :if => :current_dice_roll_robber?
      transition :before_roll => :after_roll
    end

    before_transition :on => :dice_rolled do |game, transition|
      game.playing? and game.current_user_turn?(*transition.args)
    end

    before_transition :on => :dice_rolled, :do => :add_resources

    # discarded

    event :discarded do
      transition :discard => :discard, :if => :next_player_to_discard?
      transition :discard => :robber
    end

    before_transition :on => :discarded do |game, transition|
      game.playing? and game.current_user_discard?(*transition.args)
    end

    before_transition :discard => all, :do => :player_resources_discarded?
    before_transition all => :discard, :do => :next_player_discard
    before_transition :discard => :robber, :do => :reset_robber

    # robbed

    event :robbed do
      transition :robber => :after_roll, :if => :current_dice_roll?
      transition :robber => :before_roll
    end

    before_transition :on => :robbed do |game, transition|
      game.playing? and game.current_user_turn?(*transition.args)
    end

    # end turn

    event :end_turn do
      transition :after_roll => :before_roll
    end

    before_transition :on => :end_turn do |game, transition|
      game.playing? and game.current_user_turn?(*transition.args)
    end

    before_transition :on => :end_turn, :do => :next_turn

    # card bought

    event :card_bought do
      transition :after_roll => :after_roll
    end

    before_transition :on => :card_bought do |game, transition|
      game.playing? and game.current_user_turn?(*transition.args)
    end

    # army card played

    event :army_card_played do
      transition [:before_roll, :after_roll] => :robber
    end

    before_transition :on => :army_card_played do |game, transition|
      game.playing? and game.current_user_turn?(*transition.args)
    end

    before_transition :on => :army_card_played, :do => :current_turn_card_not_played?
    before_transition :on => :army_card_played, :do => :set_current_turn_card_played
    before_transition :on => :army_card_played, :do => :largest_army

    # road building card played

    event :road_building_card_played do
      transition :after_roll => :road_building_first_road
    end

    before_transition :on => :road_building_card_played do |game, transition|
      game.playing? and game.current_user_turn?(*transition.args)
    end

    before_transition :on => :road_building_card_played, :do => :current_turn_card_not_played?
    before_transition :on => :road_building_card_played, :do => :set_current_turn_card_played

    # card played

    event :card_played do
      transition :after_roll => :after_roll
    end

    before_transition :on => :card_played do |game, transition|
      game.playing? and game.current_user_turn?(*transition.args)
    end

    before_transition :on => :card_played, :do => :current_turn_card_not_played?
    before_transition :on => :card_played, :do => :set_current_turn_card_played

    # TODO: end road building - event is not used

    event :end_road_building do
      transition [:road_building_first_road, :road_building_second_road] => :after_roll
    end

    before_transition :on => :end_road_building do |game, transition|
      game.playing? and game.current_user_turn?(*transition.args)
    end

    # offer created

    event :offer_created do
      transition :after_roll => :offer
    end

    before_transition :on => :offer_created do |game, transition|
      game.playing? and game.current_user_turn?(*transition.args)
    end

    # offer expired

    event :offer_expired do
      transition :offer => :after_roll
    end

    before_transition :on => :offer_expired do |game, transition|
      game.playing? and game.current_user_turn?(*transition.args)
    end

    # exchanged

    event :exchanged do
      transition :after_roll => :after_roll
    end

    before_transition :on => :exchanged do |game, transition|
      game.playing? and game.current_user_turn?(*transition.args)
    end
  end

  def offer
    offers.with_state(:awaiting).first
  end

  # turn

  def current_user_turn?(user)
    user.players.find_by_game_id(id) == current_player
  end

  def current_player
    players[current_player_number - 1]
  end

  def next_player?
    current_player_number < players.count
  end

  def next_player
    self.current_player_number = current_player_number + 1
    self.current_player_number = 1 if current_player_number > players.count
  end

  def previous_player?
    current_player_number != 1
  end

  def previous_player
    self.current_player_number = current_player_number - 1
    self.current_player_number = players.count if current_player_number == 0
  end

  # discard

  def current_user_discard?(user)
    user.players.find_by_game_id(id) == current_discard_player
  end

  def current_discard_player
    players[current_discard_player_number - 1]
  end

  def next_player_to_discard?
    players.exists?([%Q(resources > 7 and number > ?), current_discard_player_number])
  end

  def player_resources_discarded?
    current_discard_player_resources == current_discard_resource_limit
  end

  def next_player_discard
    player = players.find(:first, :conditions => [%Q(resources > 7 and number > ?), current_discard_player_number])
    self.current_discard_player_number = player.number
    self.current_discard_resource_limit = (player.resources + 1).div(2)
  end

  def reset_robber
    self.current_discard_player_number = 0
    self.current_discard_resource_limit = 0
  end

  # end game

  def winner?
    players.exists?([%Q(points >= 10)])
  end

  def winner
    players.find(:first, :conditions => "points >= 10")
  end

  def add_resources
    board_hexes.roll(current_dice_roll_value).each(&:rolled)
  end

  def current_dice_roll
    dice_rolls.find_by_turn(current_turn)
  end

  def current_dice_roll?
    dice_rolls.exists?(:turn => current_turn)
  end

  def next_turn
    self.current_turn += 1
    reset_current_turn_card_played
    untap_cards
    next_player
  end

  # cards

  def reset_current_turn_card_played
    self.current_turn_card_played = false
  end

  def current_turn_card_not_played?
    not current_turn_card_played
  end

  def set_current_turn_card_played
    self.current_turn_card_played = true
  end

  def untap_cards
    cards.with_state(:tapped).each(&:untap)
  end

  def take_random_card
    cards = [:army] * army_cards +
      [:monopoly] * monopoly_cards +
      [:road_building] * road_building_cards +
      [:victory_point] * victory_point_cards +
      [:year_of_plenty] * year_of_plenty_cards
    card_type = cards.rand
    self["#{card_type}_cards"] -= 1 if card_type
    card_type
  end

  def sum_cards_count
    self.cards_count = (army_cards or 0) + (monopoly_cards or 0) + (year_of_plenty_cards or 0) + (road_building_cards or 0) + (victory_point_cards or 0)
  end

  # other

  def deal_resources
    players.each do |player|
      player.bricks = player.lumber = player.ore = player.grain = player.wool = 0
      player.bricks_exchange_rate = player.grain_exchange_rate = player.lumber_exchange_rate = player.ore_exchange_rate = player.wool_exchange_rate = 4
      player.army_size = 0
      player.settlements = 5
      player.cities = 5
      player.roads = 15
      player.hidden_points = 0
      player.visible_points = 0
    end
  end

  def save_players
    players.each(&:save)
  end

  def players_ready
    players.each do |player|
      errors.add :players, "are not ready" unless player.ready?
    end
  end

  # largest army

  def largest_army_player?
    players.exists?([%Q(army_size > ?), largest_army_size])
  end

  def largest_army
    return unless largest_army_player?

    player = players.find(:first, :conditions => [%Q{army_size > ?}, largest_army_size])
    self.largest_army_size = player.army_size

    if largest_army_player != player
      if largest_army_player
        self.largest_army_player.visible_points -= 2
        largest_army_player.save
      end
      self.largest_army_player = player
      self.largest_army_player.visible_points += 2
      largest_army_player.save
    end
  end

  # longest road

  def longest_road
    new_longest_road_length = self.longest_road_length
    new_longest_road_player = nil
    edges = board_edges

    until edges.empty?
      length, visited_edges = edges.first.longest_road
      if length > new_longest_road_length
        new_longest_road_player = edges.first.player
        new_longest_road_length = length
      end
      edges -= visited_edges
    end

    if new_longest_road_player != longest_road_player
      if longest_road_player
        longest_road_player.visible_points -= 2
        longest_road_player.save
      end

      longest_road_player = new_longest_road_player

      if longest_road_player
        longest_road_player.visible_points += 2
        longest_road_player.save
      end
    end
  end
end
