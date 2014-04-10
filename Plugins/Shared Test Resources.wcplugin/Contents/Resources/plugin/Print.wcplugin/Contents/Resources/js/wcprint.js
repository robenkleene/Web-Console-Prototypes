function addOutput(output) {
	var source   = $("#output-template").html();
	var template = Handlebars.compile(source);
	var data = { 
		output: output
	};
	$(template(data)).appendTo("body");
}