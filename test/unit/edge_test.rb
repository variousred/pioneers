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

class EdgeTest < Test::Unit::TestCase
  context "With position [3, 15]" do
    setup { @edge = FactoryGirl.build(:edge, :position => [3, 15]) }

    should "return correct hex positions" do
      assert_equal [[3, 4], [3, 3]], @edge.hex_positions
    end

    should "return correct left node position" do
      assert_equal [4, 8], @edge.left_node_position
    end

    should "return correct right node position" do
      assert_equal [3, 9], @edge.right_node_position
    end

    should "return correct node positions" do
      assert_equal [[4, 8], [3, 9]], @edge.node_positions
    end

    should "return correct left edge positions" do
      assert_equal [[4, 13], [4, 14]], @edge.left_edge_positions
    end

    should "return correct right edge positions" do
      assert_equal [[3, 16], [3, 14]], @edge.right_edge_positions
    end

    should "return correct edge positions" do
      assert_equal [[4, 13], [4, 14], [3, 16], [3, 14]], @edge.edge_positions
    end
  end

  context "With position [6, 13]" do
    setup { @edge = FactoryGirl.build(:edge, :position => [6, 13]) }

    should "return correct hex positions" do
      assert_equal [[5, 3], [6, 3]], @edge.hex_positions
    end

    should "return correct left node position" do
      assert_equal [6, 7], @edge.left_node_position
    end

    should "return correct right node position" do
      assert_equal [6, 8], @edge.right_node_position
    end

    should "return correct node positions" do
      assert_equal [[6, 7], [6, 8]], @edge.node_positions
    end

    should "return correct left edge positions" do
      assert_equal [[6, 11], [6, 12]], @edge.left_edge_positions
    end

    should "return correct right edge positions" do
      assert_equal [[5, 15], [6, 14]], @edge.right_edge_positions
    end

    should "return correct edge positions" do
      assert_equal [[6, 11], [6, 12], [5, 15], [6, 14]], @edge.edge_positions
    end
  end

  context "With position [1, 20]" do
    setup { @edge = FactoryGirl.build(:edge, :position => [1, 20]) }

    should "return correct hex positions" do
      assert_equal [[0, 6], [1, 5]], @edge.hex_positions
    end

    should "return correct left node position" do
      assert_equal [1, 12], @edge.left_node_position
    end

    should "return correct right node position" do
      assert_equal [1, 13], @edge.right_node_position
    end

    should "return correct node positions" do
      assert_equal [[1, 12], [1, 13]], @edge.node_positions
    end

    should "return correct left edge positions" do
      assert_equal [[0, 21], [1, 19]], @edge.left_edge_positions
    end

    should "return correct right edge positions" do
      assert_equal [[1, 22], [1, 21]], @edge.right_edge_positions
    end

    should "return correct edge positions" do
      assert_equal [[0, 21], [1, 19], [1, 22], [1, 21]], @edge.edge_positions
    end
  end

  context "in first road phase" do
    setup do
      @edge = FactoryGirl.build(:edge)
      @hex = Object.new
      @hex.stubs(:settleable?).returns true
      @edge.stubs(:hexes).returns [@hex]
      @edge.stubs(:game_first_road?).returns(true)
      @edge.stubs(:game_second_road?).returns(false)
      @edge.stubs(:game_after_roll?).returns(false)
      @edge.stubs(:user).returns(@edge.player.user)
      @node = Object.new
#      stub!(@node)
      @node.stubs(:player).returns(@edge.player)
      @node.stubs(:has_road?).returns(false)
      @edge.stubs(:nodes).returns([@node])
      @edge.stubs(:game_road_built!).returns(true)
    end

    should "be valid with valid attributes" do
      assert @edge.valid?
    end

    should "not be valid if position is not settleable" do
      @hex.stubs(:settleable?).returns(false)
      assert !(@edge.valid?)
    end

    should "not be valid if neighbour settlement doesn't belong to player" do
      @node.stubs(:player).returns(FactoryGirl.build(:player))
      assert !(@edge.valid?)
    end

    should "not be valid if neighbour settlement has road already" do
      @node.stubs(:has_road?).returns(true)
      assert !(@edge.valid?)
    end

    should "not be valid if no settlements in neighbourhood" do
      @edge.stubs(:nodes).returns([])
      assert !(@edge.valid?)
    end

    should "take one road from player" do
      @edge.player.roads = 15
      @edge.save!
      assert_equal 14, @edge.player.roads
    end

    should "call road_built event after save" do
#      mock(@edge).game_road_built!(@edge.player.user) { |user| true }
      @edge.save!
    end
  end

  context "in after roll phase" do
    setup do
      @edge = FactoryGirl.build(:edge)
      @edge.player.attributes = { :bricks => 1, :lumber => 1 }
      @edge.player.save!
      @hex = Object.new
      @hex.stubs(:settleable?).returns true
      @edge.stubs(:hexes).returns([@hex])
      @edge.stubs(:game_first_road?).returns(false)
      @edge.stubs(:game_second_road?).returns(false)
      @edge.stubs(:game_after_roll?).returns(true)
      @edge.stubs(:user).returns(@edge.player.user)
      @edge.stubs(:game_road_built!)
    end

    context "with settlement in neighbourhood" do
      setup do
        @node = Object.new
        @node.stubs(:player).returns(@edge.player)
        @edge.stubs(:nodes).returns([@node])
      end

      should "be valid with valid attributes" do
        assert @edge.valid?
      end

      should "not be valid if player has no bricks" do
        @edge.player.attributes = { :bricks => 0 }
        @edge.player.save!
        assert !(@edge.valid?)
      end

      should "not be valid if player has no lumber" do
        @edge.player.attributes = { :lumber => 0 }
        @edge.player.save!
        assert !(@edge.valid?)
      end

      should "not be valid if player has no roads" do
        @edge.player.attributes = { :roads => 0 }
        @edge.player.save!
        assert !(@edge.valid?)
      end

      should "not be valid if settlement doesn't belong to player" do
        @node.stubs(:player).returns(FactoryGirl.build(:player))
        assert !(@edge.valid?)
      end
    end

    context "with road in left neighbourhood" do
      setup do
        @edge2 = Object.new
        @edge2.stubs(:player).returns(@edge.player)
        @edge.stubs(:left_edges).returns([@edge2])
      end

      should "be valid with valid attributes" do
        assert @edge.valid?
      end

      should "not be valid if road doesn't belong to player" do
        @edge2.stubs(:player).returns(FactoryGirl.build(:player))
        assert !(@edge.valid?)
      end

      should "not be valid if left road belong to player but left settlement doesn't" do
        @node = Object.new
        @node.stubs(:player).returns(FactoryGirl.build(:player))
        @edge.stubs(:left_node).returns(@node)
        assert !(@edge.valid?)
      end
    end
  end
end
