Mousetrap.bind('down', function() {
	Bullets.selectNext();
    return false;
});

Mousetrap.bind('up', function() {
	Bullets.selectPrevious();
    return false;
});

Mousetrap.bind('return', function() {
	Bullets.followSelection();
    return false;
});