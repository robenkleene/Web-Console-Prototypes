# Index

## Presentation

* [x] Record screencasts
* [x] Add license
* [x] Write Readme
* [x] Post to Github
* [x] Make a link on 1Percenter
* [ ] Downgrade to GPLv2?
	* Research Apple's reasons for not upgrading to GPLv3 software
	* Research GPLv2 and app store
* [ ] Add README to TextMate bundle (installation instructions)
* [ ] Setup link to `PluginEditorPrototype` description and screenshots
* [ ] Review on non-retina screen

## Testing

* [ ] Test Web Console application missing TextMate bundle on Virtual Machine

## Continued

* [ ] Quick edit, don't have to specify XIB files by name: "Or if iOS finds a nib file in the app bundle with a name based on the view controller’s class name." UIViewController, loadView
* [ ] Rename from `Web Console` to `WebConsole`?
* [ ] Do `PluginEditorPrototype` screenshots
* [ ] Shell Scripts
	* These require the Ruby gem
	* For now just `gem install webconsole` globally
	* Test the HTML and Markdown Gems on Virtual Machine
	* Build a command line utility to run these?
	* Scripts
		* `wccoffee.rb`
		* `wchtml.rb`
		* `wcirb.rb`
		* `wcmarkdown.rb`
		* `wcnode.rb`
		* `wcsearch.rb`
* [ ] `http` links should open in the browser?
	* Test `WebConsole::Dependencies` works with this (e.g., linking to "homebrew" opens in the browser)
* [ ] Provide an `plist` option to kill a Plugin without confirming
* [ ] REPL output controller shouldn't be removing blank lines to properly render output like this: `puts "blah\n\n\nblah"`. Note this requires a gem update.
* [ ] Base URL for Markdown plugin has problems because right now it is the relative to the plugin directory for accessing template resources, but it must be able to add resources relative to the markdown file itself (images, etc...) as well