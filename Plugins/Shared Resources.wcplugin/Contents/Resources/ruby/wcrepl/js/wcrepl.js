var WcREPL = {
	addCode: function(code, source) {
		var template = Handlebars.compile(source);
		var data = { 
			code: code
		};
		return $(template(data)).appendTo("body");	
	},
	addInput: function(code) {
		var source = $("#input-template").html();
		this.addCode(code, source);
	},
	addOutput: function(code) {
		var source = $("#output-template").html();
		this.addCode(code, source);
	}
}