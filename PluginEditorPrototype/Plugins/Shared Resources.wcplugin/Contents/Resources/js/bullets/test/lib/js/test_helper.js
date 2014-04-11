var testhelper = {
	testSelection: function() {
		Bullets.selection.length.should.equal(1);
		var testSelection = document.activeElement;
		var selection = Bullets.selection[0];
		selection.should.equal(testSelection);
		selection.id.should.equal(Bullets.selected)
		$(Bullets.selectedID).length.should.equal(1);
	},
	testNoSelection: function() {
		Bullets.selection.length.should.equal(0);
		document.activeElement.should.equal(document.body);
		$(Bullets.selectedID).length.should.equal(0);
	},
	testSelectionMatchesIndex: function(index) {
		var testText = testhelper.textOf(Bullets.tags, index);
		var bulletsText = Bullets.selection.text();
		bulletsText.should.equal(testText);
	},

	// Private
	textOf: function(tag, index) {
		return $(tag).eq(index).text();
	}

}