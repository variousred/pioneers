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

require 'test_helper'

class NodeTest < Test::Unit::TestCase
  context "With position [3, 10]" do
    setup { @node = FactoryGirl.build(:node, :position => [3, 10]) }

    should "return correct hex positions" do
      assert_equal [[2, 5], [2, 4], [3, 4]], @node.hex_positions
    end

    should "return correct edge positions" do
      assert_equal [[2, 18], [3, 16], [3, 17]], @node.edge_positions
    end

    should "return correct node positions" do
      assert_equal [[2, 11], [3, 9], [3, 11]], @node.node_positions
    end
  end

  context "With position [6, 7]" do
    setup { @node = FactoryGirl.build(:node, :position => [6, 7]) }

    should "return correct hex positions" do
      assert_equal [[5, 3], [6, 2], [6, 3]], @node.hex_positions
    end

    should "return correct edge positions" do
      assert_equal [[6, 13], [6, 11], [6, 12]], @node.edge_positions
    end

    should "return correct node positions" do
      assert_equal [[6, 8], [6, 6], [7, 6]], @node.node_positions
    end
  end

  context "validations" do
    setup do
      @node = FactoryGirl.build(:node)
      @hex = Object.new
      @hex.stubs(:settleable?).returns(true)
      @hex.stubs(:harbor_on?).returns(false)
      @node.stubs(:nodes).returns([])
      @node.stubs(:hexes).returns([@hex])
      @node.stubs(:user).returns(@node.player.user)
      @node.stubs(:user_player).returns(@node.player)
      @node.stubs(:game_settlement_built!).returns(true)
    end

    context "in first settlement phase" do
      setup do
        @node.stubs(:game_first_settlement?).returns(true)
        @node.stubs(:game_second_settlement?).returns(false)
        @node.stubs(:game_after_roll?).returns(false)
      end

      should "be valid with valid attributes" do
        assert @node.valid?
      end

      should "not be valid with node in neighbourhood" do
        @node.stubs(:nodes).returns([FactoryGirl.build(:node)])
        assert !@node.valid?
      end

      should "not be valid if position is not settleable" do
        @hex.stubs(:settleable?).returns(false)
        assert !@node.valid?
      end

      should "not be valid if player has changed" do
        @node.stubs(:user_player).returns(FactoryGirl.build(:player))
        assert !@node.valid?
      end

      should "take one settlement from player after save" do
        @node.player.settlements = 5
        @node.save!
        assert_equal 4, @node.player.settlements
      end

      should "modify player's exchange rates if generic harbor" do
        @node.player.bricks_exchange_rate = 2
        @node.player.grain_exchange_rate = 2
        @hex.stubs(:harbor_on?).returns(true)
        @hex.stubs(:harbor_type).returns("generic")
        @node.save!
        assert_equal 2, @node.player.bricks_exchange_rate
        assert_equal 2, @node.player.grain_exchange_rate
        assert_equal 3, @node.player.lumber_exchange_rate
        assert_equal 3, @node.player.ore_exchange_rate
        assert_equal 3, @node.player.wool_exchange_rate
      end

      should "modify player's exchange rates if lumber harbor" do
        @hex.stubs(:harbor_on?).returns(true)
        @hex.stubs(:harbor_type).returns("lumber")
        @node.save!
        assert_equal 4, @node.player.bricks_exchange_rate
        assert_equal 4, @node.player.grain_exchange_rate
        assert_equal 2, @node.player.lumber_exchange_rate
        assert_equal 4, @node.player.ore_exchange_rate
        assert_equal 4, @node.player.wool_exchange_rate
      end

      should "have state 'settlement' after save" do
        @node.save!
        assert @node.settlement?
      end

      should "not be valid when player has not enough settlements" do
        @node.player.settlements = 0
        assert !@node.valid?
      end

      should "not charge player for settlement" do
        @node.player.attributes = {
          :bricks => 1,
          :grain => 1,
          :lumber => 1,
          :wool => 1
        }
        @node.save!
        assert_equal 1, @node.player.bricks
        assert_equal 1, @node.player.grain
        assert_equal 1, @node.player.lumber
        assert_equal 1, @node.player.wool
      end

      should "add one visible victory point to player" do
        @node.player.visible_points = 1
        @node.save!
        assert_equal 2, @node.player.visible_points
      end

      should "call game_settlement_built! after save" do
#        mock(@node).game_settlement_built!(@node.player.user) { true }
        @node.save!
      end
    end

    context "in second settlement phase" do
      setup do
        @node.stubs(:game_first_settlement?).returns(false)
        @node.stubs(:game_second_settlement?).returns(true)
        @node.stubs(:game_after_roll?).returns(false)
        @hex.stubs(:resource_type).returns(nil)
      end

      should "not charge player for settlement" do
        @node.player.attributes = {
          :bricks => 1,
          :grain => 1,
          :lumber => 1,
          :ore => 1,
          :wool => 1
        }
        @node.save!
        assert_equal 1, @node.player.bricks
        assert_equal 1, @node.player.grain
        assert_equal 1, @node.player.lumber
        assert_equal 1, @node.player.ore
        assert_equal 1, @node.player.wool
      end

      should "add resources from neighbour hexes" do
        @hex.stubs(:resource_type).returns("lumber")
        @node.player.attributes = {
          :bricks => 1,
          :grain => 1,
          :lumber => 1,
          :ore => 1,
          :wool => 1
        }
        @node.save!
        assert_equal 1, @node.player.bricks
        assert_equal 1, @node.player.grain
        assert_equal 2, @node.player.lumber
        assert_equal 1, @node.player.ore
        assert_equal 1, @node.player.wool
      end

      should "call game_settlement_built! after save" do
#        mock(@node).game_settlement_built!(@node.player.user) { true }
        @node.save!
      end
    end

    context "in after roll phase" do
      setup do
        @node.stubs(:game_first_settlement?).returns(false)
        @node.stubs(:game_second_settlement?).returns(false)
        @node.stubs(:game_after_roll?).returns(true)
        @edge = Object.new
        @edge.stubs(:player).returns(@node.player)
        @node.stubs(:edges).returns([@edge])
        @node.player.attributes = {
          :bricks => 1,
          :grain => 1,
          :lumber => 1,
          :ore => 1,
          :wool => 1
        }
      end

      should "charge player for settlement" do
        @node.save!
        assert_equal 0, @node.player.bricks
        assert_equal 0, @node.player.grain
        assert_equal 0, @node.player.lumber
        assert_equal 1, @node.player.ore
        assert_equal 0, @node.player.wool
      end

      should "not be valid without road" do
        @node.stubs(:edges).returns([])
        assert !@node.valid?
      end

      should "not be valid with road of other player" do
        @edge = Object.new
        @edge.stubs(:player).returns(FactoryGirl.build(:player))
        @node.stubs(:edges).returns([@edge])
        assert !@node.valid?
      end

      should "not allow to expand settlement if player has not enough resources" do
        @node.save!
        @node.reload
        @node.state_event = "expand"
        assert !@node.valid?
      end

      should "charge player for city if player has enough resources" do
        @node.save!
        @node.reload
        @node.player.attributes = {
          :bricks => 0,
          :grain => 2,
          :lumber => 0,
          :ore => 3,
          :wool => 0,
          :settlements => 4,
          :cities => 4,
          :visible_points => 1
        }
        @node.state_event = "expand"
        @node.save!
        @node.reload
        assert @node.city?
        assert_equal 0, @node.player.bricks
        assert_equal 0, @node.player.grain
        assert_equal 0, @node.player.lumber
        assert_equal 0, @node.player.ore
        assert_equal 0, @node.player.wool
        assert_equal 5, @node.player.settlements
        assert_equal 3, @node.player.cities
        assert_equal 2, @node.player.visible_points
      end
    end
  end
end
