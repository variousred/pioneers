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

YUI.add("resources", function(Y) {
    var RESOURCES = "resources",
        CONTENT_BOX = "contentBox",
        getCN = Y.ClassNameManager.getClassName,
        C_BUTTON = getCN(RESOURCES, "accept"),
        BUTTON_TEMPLATE = '<button type="button" class="' + C_BUTTON + '"></button>',
        C_LABEL = getCN(RESOURCES, "label"),
        LABEL_TEMPLATE = '<label class="' + C_LABEL + '"></label>',
        Widget = Y.Widget,
        Node = Y.Node,
        isNumber = Y.Lang.isNumber,
        bind = Y.bind,
        ResourceSpinner = Y.ResourceSpinner;

    function Resources() {
        Resources.superclass.constructor.apply(this, arguments);
    }

    Y.mix(Resources, {
        NAME: RESOURCES,
        ATTRS: {
            value: {
                readOnly: true,
                getter: function() {
                    return this._getSpinnersValues();
                }
            },
            min: {
                value: {
                    bricks: 0,
                    grain: 0,
                    lumber: 0,
                    ore: 0,
                    wool: 0
                }
            },
            max: {
                value: {
                    bricks: 0,
                    grain: 0,
                    lumber: 0,
                    ore: 0,
                    wool: 0
                }
            },
            steps: {
                value: {
                    bricks: 1,
                    grain: 1,
                    lumber: 1,
                    ore: 1,
                    wool: 1
                }
            },
            label: {
                value: "Resources"
            },
            strings: {
                value: {
                    accept: "Accept",
                    bricks: "Bricks",
                    grain: "Grain",
                    lumber: "Lumber",
                    ore: "Ore",
                    wool: "Wool"
                }
            }
        }
    });

    Y.extend(Resources, Widget, {
        renderUI: function() {
            this._renderLabel();
            this._renderSpinners();
            this._renderAcceptButton();
        },

        bindUI: function() {
            this.after("disabledChange", this._afterDisabledChange);
            this.after("minChange", this._afterMinChange);
            this.after("maxChange", this._afterMaxChange);
            this.after("stepsChange", this._afterStepsChange);
            this.bricksSpinner.after("valueChange", bind(this._afterSpinnerValueChange, this));
            this.grainSpinner.after("valueChange", bind(this._afterSpinnerValueChange, this));
            this.lumberSpinner.after("valueChange", bind(this._afterSpinnerValueChange, this));
            this.oreSpinner.after("valueChange", bind(this._afterSpinnerValueChange, this));
            this.woolSpinner.after("valueChange", bind(this._afterSpinnerValueChange, this));
        },

        reset: function() {
            Resources.superclass.reset.apply(this, arguments);
            this.bricksSpinner.set("value", 0);
            this.grainSpinner.set("value", 0);
            this.lumberSpinner.set("value", 0);
            this.oreSpinner.set("value", 0);
            this.woolSpinner.set("value", 0);
        },

        _afterDisabledChange: function(event) {
            this.bricksSpinner.set("disabled", event.newVal);
            this.grainSpinner.set("disabled", event.newVal);
            this.lumberSpinner.set("disabled", event.newVal);
            this.oreSpinner.set("disabled", event.newVal);
            this.woolSpinner.set("disabled", event.newVal);
            this.syncUI();
        },

        _afterSpinnerValueChange: function() {
            this._uiSyncButton(this.get("value"));
        },

        syncUI : function() {
            this._uiSetMin(this.get("min"));
            this._uiSetMax(this.get("max"));
            this._uiSetSteps(this.get("steps"));
            this._uiSyncButton(this.get("value"));
        },

        _afterStepsChange: function(event) {
            this._uiSetSteps(event.newVal);
            this._uiSyncButton(this.get("value"));
        },

        _afterMinChange: function(event) {
            this._uiSetMin(event.newVal);
            this._uiSyncButton(this.get("value"));
        },

        _afterMaxChange: function(event) {
            this._uiSetMax(event.newVal);
            this._uiSyncButton(this.get("value"));
        },

        _uiSyncButton: function(value) {
            var disabled = this.get("disabled");
            this.acceptButton.set("disabled", disabled || !this._validateValue(value));
        },

        _getSpinnersValues: function() {
            return {
                bricks: this.bricksSpinner.get("value"),
                grain: this.grainSpinner.get("value"),
                lumber: this.lumberSpinner.get("value"),
                ore: this.oreSpinner.get("value"),
                wool: this.woolSpinner.get("value")
            };
        },

        _renderLabel: function() {
            var contentBox = this.get(CONTENT_BOX),
                labelString = this.get("label");

            var label = Y.Node.create(LABEL_TEMPLATE);
            label.set("innerHTML", labelString);

            this.labelNode = contentBox.appendChild(label);
        },

        _renderSpinners: function() {
            var strings = this.get("strings");
            this.bricksSpinner = this._createSpinner("bricks", strings.bricks);
            this.grainSpinner = this._createSpinner("grain", strings.grain);
            this.lumberSpinner = this._createSpinner("lumber", strings.lumber);
            this.oreSpinner = this._createSpinner("ore", strings.ore);
            this.woolSpinner = this._createSpinner("wool", strings.wool);
        },

        _createSpinner: function(name, label) {
            var contentBox = this.get(CONTENT_BOX),
                className = this.getClassName(name);

            var spinnerNode = Node.create('<div class="' + className + '"></div>');
            var spinner = new ResourceSpinner({ contentBox: spinnerNode, label: label });

            contentBox.appendChild(spinnerNode);
            spinner.render();

            return spinner;
        },

        _renderAcceptButton: function() {
            var contentBox = this.get(CONTENT_BOX),
                acceptButton = Node.create(BUTTON_TEMPLATE),
                strings = this.get("strings");

            acceptButton.set("innerHTML", strings.accept);
            acceptButton.set("title", strings.accept);

            this.acceptButton = acceptButton;

            contentBox.appendChild(acceptButton);
        },

        _validateValue: function(value) {
            return isNumber(value.bricks) &&
                isNumber(value.grain) &&
                isNumber(value.lumber) &&
                isNumber(value.ore) &&
                isNumber(value.wool) &&
                this._isNotZero(value);
        },

        _isNotZero: function(value) {
            return value.bricks !== 0 ||
                value.grain !== 0 ||
                value.lumber !== 0 ||
                value.ore !== 0 ||
                value.wool !== 0;
        },

        _uiSetMin: function(min) {
            this.bricksSpinner.set("min", min.bricks);
            this.grainSpinner.set("min", min.grain);
            this.lumberSpinner.set("min", min.lumber);
            this.oreSpinner.set("min", min.ore);
            this.woolSpinner.set("min", min.wool);
        },

        _uiSetMax: function(max) {
            this.bricksSpinner.set("max", max.bricks);
            this.grainSpinner.set("max", max.grain);
            this.lumberSpinner.set("max", max.lumber);
            this.oreSpinner.set("max", max.ore);
            this.woolSpinner.set("max", max.wool);
        },

        _uiSetSteps: function(steps) {
            this.bricksSpinner.set("step", steps.bricks);
            this.grainSpinner.set("step", steps.grain);
            this.lumberSpinner.set("step", steps.lumber);
            this.oreSpinner.set("step", steps.ore);
            this.woolSpinner.set("step", steps.wool);
        }
    });

    Y.Resources = Resources;

}, '0.0.1', { requires: ["widget", "resource-spinner"] });
