// Pioneers - web game based on the Settlers of Catan board game.

// Copyright (C) 2009 Jakub Kuźma <qoobaa@gmail.com>

// This program is free software: you can redistribute it and/or
// modify it under the terms of the GNU Affero General Public License
// as published by the Free Software Foundation, either version 3 of
// the License, or (at your option) any later version.

// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Affero General Public License for more details.

// You should have received a copy of the GNU Affero General Public
// License along with this program.  If not, see
// <http://www.gnu.org/licenses/>.

YUI.add("offer", function(Y) {
    var OFFER = "offer",
        CONTENT_BOX = "contentBox",
        Resources = Y.Resources,
        bind = Y.bind;

    function Offer() {
        Offer.superclass.constructor.apply(this, arguments);
    }

    Y.mix(Offer, {
        NAME: OFFER,
        ATTRS: {
            label: {
                value: "Offer"
            },
            game: {
            },
            max: {
                value: {
                    bricks: 19,
                    grain: 19,
                    lumber: 19,
                    ore: 19,
                    wool: 19
                }
            },
            min: {
                readOnly: true,
                getter: function() {
                    var game = this.get("game"),
                        player = game.userPlayer(),
                        bricks = player.get("bricks"),
                        grain = player.get("grain"),
                        lumber = player.get("lumber"),
                        ore = player.get("ore"),
                        wool = player.get("wool");
                    return {
                        bricks: - bricks,
                        grain: - grain,
                        lumber: - lumber,
                        ore: - ore,
                        wool: - wool
                    };
                }
            }
        }
    });

    Y.extend(Offer, Resources, {
        _validateValue: function(value) {
            return Offer.superclass._validateValue.apply(this, arguments) &&
                this._isValidOffer(value);
        },

        _isValidOffer: function(value) {
            var minus = value.bricks < 0 ||
                value.grain < 0 ||
                value.lumber < 0 ||
                value.ore < 0 ||
                value.wool < 0;
            var plus = value.bricks > 0 ||
                value.grain > 0 ||
                value.lumber > 0 ||
                value.ore > 0 ||
                value.wool > 0;
            return minus && plus;
        },

        bindUI: function() {
            Offer.superclass.bindUI.apply(this, arguments);
            this.acceptButton.after("click", Y.bind(this._afterAcceptClick, this));
        },

        _afterAcceptClick: function(event) {
            var values = this._getSpinnersValues();

            this.fire(OFFER, values);
        }
    });

    Y.Offer = Offer;

}, '0.0.1', { requires: ["resources"] });
