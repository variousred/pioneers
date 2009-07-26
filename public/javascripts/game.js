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

YUI.add("game", function(Y) {

    var GAME = "game",
        getCN = Y.ClassNameManager.getClassName,
        C_GAME = getCN(GAME),
        CONTENT_BOX = "contentBox",
        DIV_TEMPLATE = '<div></div>',
        Widget = Y.Widget,
        Node = Y.Node,
        bind = Y.bind,
        isValue = Y.Lang.isValue,
        pioneers = Y.namespace("pioneers");

    function Game() {
        Game.superclass.constructor.apply(this, arguments);
    }

    Y.mix(Game, {
        NAME: GAME,
        ATTRS: {
            game: {
                writeOnce: true
            }
        }
    });

    Y.extend(Game, Widget, {
        renderUI: function() {
            this._renderBoard();
            this._renderExchange();
            this._renderDiscard();
            this._renderOffer();
            this._renderBuild();
            this._renderCards();
            this._renderBeforeRoll();
        },

        _renderBoard: function() {
            var game = this.get("game"),
                board = game.board,
                player = game.get("userPlayer"),
                contentBox = this.get(CONTENT_BOX),
                boardNode = Node.create(DIV_TEMPLATE);

            this.board = new Y.Board({ game: game, contentBox: boardNode });
            contentBox.append(boardNode);

            this.board.render();
        },

        _renderExchange: function() {
            var game = this.get("game"),
                player = game.get("userPlayer"),
                contentBox = this.get(CONTENT_BOX),
                exchangeNode = Node.create(DIV_TEMPLATE);

            if(isValue(player)) {
                this.exchange = new Y.Exchange({ contentBox: exchangeNode, game: game });
                contentBox.append(exchangeNode);

                this.exchange.render();
            }
        },

        _renderDiscard: function() {
            var game = this.get("game"),
                player = game.get("userPlayer"),
                contentBox = this.get(CONTENT_BOX),
                discardNode = Node.create(DIV_TEMPLATE);

            if(isValue(player)) {
                this.discard = new Y.Discard({ contentBox: discardNode, game: game });
                contentBox.append(discardNode);

                this.discard.render();
            }
        },

        _renderOffer: function() {
            var game = this.get("game"),
                player = game.get("userPlayer"),
                contentBox = this.get(CONTENT_BOX),
                offerNode = Node.create(DIV_TEMPLATE);

            if(isValue(player)) {
                this.offer = new Y.Offer({ contentBox: offerNode, game: game });
                contentBox.append(offerNode);

                this.offer.render();
            }
        },

        _renderBuild: function() {
            var game = this.get("game"),
                player = game.get("userPlayer"),
                contentBox = this.get(CONTENT_BOX),
                buildNode = Node.create(DIV_TEMPLATE);

            if(isValue(player)) {
                this.build = new Y.Build({ contentBox: buildNode, game: game });
                contentBox.append(buildNode);

                this.build.render();
            }
        },

        _renderCards: function() {
            var game = this.get("game"),
                player = game.get("userPlayer"),
                cards = game.get("userCards"),
                contentBox = this.get(CONTENT_BOX),
                cardsNode = Node.create(DIV_TEMPLATE);

            if(isValue(player)) {
                this.cards = new Y.Cards({ contentBox: cardsNode, cards: cards });
                contentBox.append(cardsNode);

                this.cards.render();
            }
        },

        _renderBeforeRoll: function() {
            var game = this.get("game"),
                player = game.get("userPlayer"),
                cards = game.get("userCards"),
                contentBox = this.get(CONTENT_BOX),
                beforeRollNode = Node.create(DIV_TEMPLATE);

            if(isValue(player)) {
                this.beforeRoll = new Y.BeforeRoll({ contentBox: beforeRollNode, cards: cards });
                contentBox.append(beforeRollNode);

                this.beforeRoll.render();
            }
        },

        syncUI: function() {

        }

    });

    Y.Game = Game;

}, '0.0.1', { requires: ["widget", "pioneers-game", "board", "exchange", "discard", "offer", "build", "cards", "before-roll"] });
