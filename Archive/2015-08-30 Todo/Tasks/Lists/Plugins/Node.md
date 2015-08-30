# Node

- This appears to have a bug where sometimes the REPL output is proceeded by the ">" character and therefore the output gets lost, the following code illustrates it, printing "The Title" is proceeded by the node prompt for some reason

		var jsdom = require("jsdom");
		var window = jsdom.jsdom().parentWindow;
		jsdom.jQueryify(window, "http://code.jquery.com/jquery.js", function () {
		  var $ = window.$;
		  $("body").prepend("<h1>The title</h1>");
		  console.log($("h1").html());
		});
