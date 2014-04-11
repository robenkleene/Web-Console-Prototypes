// DOM Manipulation

function addFile(filePath, displayFilePath) {
	var source   = $("#file-template").html();
	var template = Handlebars.compile(source);
	var data = { 
		filePath: filePath,
		displayFilePath: displayFilePath
	};
	$(template(data)).appendTo("body");
}

function addLine(number, text, matches) {
	var matchesCopy = JSON.parse(JSON.stringify(matches));
	text = textWithMatchesProcessed(text, 0, matchesCopy);

	var source   = $("#line-template").html();
	var template = Handlebars.compile(source);
	var data = { 
		number: number,
		text: text
	};
	var list = $('section ul').last();
	$(template(data)).appendTo(list);
}

// String processing

function textWithMatchesProcessed(text, startIndex, matches) {
	if (matches.length > 0) {
		match = matches[0];
		matches.splice(0,1);

		var source = $("#match-template").html();
		var template = Handlebars.compile(source);
		var beforeMatchLength = match.index - startIndex;
		var beforeMatch = escapeHTML(text.substr(startIndex, beforeMatchLength));
		var matchedText = text.substr(match.index, match.length);
		var data = {
			text: matchedText
		};

		var templatedText = template(data).stripWhitespace(); // Handlebars does internal escaping

		textWithMatchSubstring = beforeMatch + templatedText;

		var nextStartIndex = match.index + match.length;

		return textWithMatchSubstring + textWithMatchesProcessed(text, nextStartIndex, matches)
	}

	return escapeHTML(text.substr(startIndex));
}

// Helpers

String.prototype.stripWhitespace=function() {
	return this.replace(/(^\s+|\s+$)/g, '');
}

var entityMap = {
   "&": "&amp;",
   "<": "&lt;",
   ">": "&gt;",
   '"': '&quot;',
   "'": '&#39;',
   "/": '&#x2F;'
};
function escapeHTML(string) {
	return String(string).replace(/[&<>"'\/]/g, function (s) {
		return entityMap[s];
	});
}
