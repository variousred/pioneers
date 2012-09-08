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

FactoryGirl.define do
  factory :player do |p|
  p.bricks 0
  p.bricks_exchange_rate 4
  p.grain 0
  p.grain_exchange_rate 4
  p.ore 0
  p.ore_exchange_rate 4
  p.wool 0
  p.wool_exchange_rate 4
  p.lumber 0
  p.lumber_exchange_rate 4
  p.settlements 5
  p.cities 4
  p.roads 15
  p.points 0
  p.visible_points 0
  p.hidden_points 0
  p.association :user, :factory => :user
end
end
