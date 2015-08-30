# Git

* Work on `git_manager`
* Start working on converting the rest of the handlebars templates to Slim
	* Create behavior for adding files of various types
* Just get the example working with Slim and experiment using it as a template-ing engine and determine whether I want to support this or just use ERB
	* For now I'm subclassing `WebConsole::Controller`, but if I decide I want to support Slim, figure out a more elegant way of support various rendering engines
	* This should probably just be methods on the controller, e.g., `render_slim`, etc...
* Setup a testing solution, `PhantomJS`?
	* Don't use `PhantomJS` for this, just set it up as a real plugin and use Ruby Test Unit -- I might night to write a controller subclass that uses Jade?
	* Write a `PhantomJS` wrapper that uses the `webconsole` API to run stuff headless?
		* Test Class, `HeadlessWindowManager`
		* This should be set=able by running with a flag
* Figure out table layout in view for git data
	* Build a set of handlebars templates generated from JSON
* `controller.rb` takes a path on `init`, this is the path that is being operated on
* Make the title show the path
* Make Makefile for git Ruby tests
	* Add to main tests