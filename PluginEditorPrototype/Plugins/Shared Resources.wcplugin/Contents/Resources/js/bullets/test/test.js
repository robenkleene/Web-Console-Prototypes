describe('Bullets', function() {
	after(function() {
		Bullets.deselect();
	});
	describe('deselect', function() {
		it('should deselect the selection when it is passed in', function () {
			Bullets.selectNext();
			testhelper.testSelection();
			Bullets.deselect(Bullets.selection);
			testhelper.testNoSelection();
		});
		it('should deselect the selection when nothing is passed in', function () {
			Bullets.selectNext();
			testhelper.testSelection();
			Bullets.deselect();
			testhelper.testNoSelection();
		});
	});

	describe('selectNext', function() {
	    afterEach(function() {
			Bullets.deselect();
	    });
		it('should select the first tag when nothing is selected', function() {
			Bullets.selectNext();
			testhelper.testSelection();
			testhelper.testSelectionMatchesIndex(0);
		});
		it('should select the next tag after the selection', function() {
			Bullets.selectNext();
			Bullets.selectNext();
			testhelper.testSelection();
			testhelper.testSelectionMatchesIndex(1);
		});
		it('should keep the same selected tag when the last tag is selected', function() {
			Bullets.selectPrevious();
			Bullets.selectNext();
			testhelper.testSelection();
			testhelper.testSelectionMatchesIndex(-1);
		});
	});

	describe('selectPrevious', function() {
	    afterEach(function() {
			Bullets.deselect();
	    });
		it('should select the last tag when nothing is selected', function() {
			Bullets.selectPrevious();
			testhelper.testSelection();
			testhelper.testSelectionMatchesIndex(-1);
		});
		it('should select the previous tag before the selection', function() {
			Bullets.selectPrevious();
			Bullets.selectPrevious();
			testhelper.testSelection();
			testhelper.testSelectionMatchesIndex(-2);
		});
		it('should keep the same selected tag when the first tag is selected', function() {
			Bullets.selectNext();
			Bullets.selectPrevious();
			testhelper.testSelection();
			testhelper.testSelectionMatchesIndex(0);
		});
	});


	describe('focus and blur', function() {
		var blurCount;
		var focusCount;
		before(function () {
			$(Bullets.tags).focus(function() {
				focusCount++;
			});
			$(Bullets.tags).blur(function() {
				blurCount++;
			});
		});
		after(function() {
		    $(Bullets.tags).unbind('blur') ; 
		    $(Bullets.tags).unbind('focus') ;
		});
		beforeEach(function() {
			Bullets.deselect();
			blurCount = 0;
			focusCount = 0;
		});
		it('only focus should run when the next tag is selected', function() {
			var testFocusCount = 0;
			var testBlurCount = 0;

			Bullets.selectNext();
			testFocusCount++;
			focusCount.should.equal(testFocusCount);
			blurCount.should.equal(testBlurCount);
		});
		it('focus and blur should not run when the selection doen\'t change', function() {
			var testFocusCount = 0;
			var testBlurCount = 0;

			Bullets.selectNext();
			testFocusCount++;
			focusCount.should.equal(testFocusCount);
			blurCount.should.equal(testBlurCount);

			Bullets.selectPrevious();
			focusCount.should.equal(testFocusCount);
			blurCount.should.equal(testBlurCount);
		});
		it('focus and blur should each fire once when the selection changes', function() {
			var testFocusCount = 0;
			var testBlurCount = 0;

			Bullets.selectNext();
			testFocusCount++;
			focusCount.should.equal(testFocusCount);
			blurCount.should.equal(testBlurCount);

			Bullets.selectNext();
			testFocusCount++;
			testBlurCount++;
			focusCount.should.equal(testFocusCount);
			blurCount.should.equal(testBlurCount);

			Bullets.selectNext();
			testFocusCount++;
			testBlurCount++;
			focusCount.should.equal(testFocusCount);
			blurCount.should.equal(testBlurCount);
		});
	});
});
