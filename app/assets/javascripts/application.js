//= require jquery
//= require jquery_ujs

//= require pioneers/board
//= require pioneers/edge
//= require pioneers/game
//= require pioneers/hex
//= require pioneers/node
//= require pioneers/offer
//= require pioneers/player
//= require pioneers/position

//= require widgets/after-roll
//= require widgets/before-roll
//= require widgets/board
//= require widgets/build
//= require widgets/cards
//= require widgets/discard
//= require widgets/exchange
//= require widgets/game-status
//= require widgets/game
//= require widgets/join
//= require widgets/monopoly
//= require widgets/offer-received
//= require widgets/offer-sent
//= require widgets/offer
//= require widgets/players
//= require widgets/resource-spinner
//= require widgets/resources
//= require widgets/user-player
//= require widgets/year-of-plenty

<script src="http://yui.yahooapis.com/3.6.0/build/yui/yui-min.js"></script>

YUI().use("io-base", "json-parse", "game", "overlay", function(Y) {
    var parse = Y.JSON.parse,
        io = Y.io,
        pathname = document.location.pathname;

    if(pathname.match(/^\/games\/\d+$/)) {
        function success(id, response) {
            var gameAttributes = parse(response.responseText),
                gameObject = new Y.pioneers.Game(gameAttributes);

            var game = new Y.Game({ game: gameObject });

            game.render();
        };

        var request = io(pathname + ".json", { on: { success: success } });
    }
});
