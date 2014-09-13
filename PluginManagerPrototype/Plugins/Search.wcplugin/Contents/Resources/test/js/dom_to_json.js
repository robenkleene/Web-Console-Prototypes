function DOMToJSON() {
	var matches = [];

	$('section').each(function () {
		a = $('a' , this).first()
		var displayFilePath = a.text();
		var filePath = a.attr("href").replace('file://','');

		$('li', this).each(function () {
			var strongElements = $('strong', this).toArray();
			var numberElement = strongElements.shift();
			var lineNumber = $(numberElement).text().replace(':','');

			$(strongElements).each(function () {
				matchedText = $(this).text();

				var match = new Object();
				match.display_file_path = displayFilePath;
				match.file_path = filePath;
				match.line_number = lineNumber;
				match.matched_text = matchedText;

				matches.push(match);
			});
		});
	});

	return JSON.stringify(matches);
}
DOMToJSON();