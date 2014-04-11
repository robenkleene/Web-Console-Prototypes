WcREPL.oldAddCode = WcREPL.addCode;
WcREPL.addCode = function(code, source) {
	var $newcode = this.oldAddCode(code, source);
	$(document).ready(function() {
	  $newcode.each(function(i, e) {
		  hljs.highlightBlock(e);
	  });
	});
};