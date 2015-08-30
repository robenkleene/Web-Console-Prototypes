# Someday

* Parser for tests output
	* Highlight test failures and success summaries
	* Show warnings
* Make irb terminate cleanly on interrupt
	* Right now I think irb is only closing because it gets sent the interrupt signal and then the terminate signal
		* When this happens I should log it to the console
* HTML Fragments Concept as a good AppleScript test
* Plugin names should be case insensitive?
* Figure out how to make a AppleScript fail with an error
	* E.g., no plugin with name found
* Web Console command line utility
	* Symlink to the script in the app bundle
	* Figure out how to handle passing in the directory the plugin was run from
		* Probably "in directory" which passes in the the folder the script was run in?
		* I pass in the "in directory" parameter, then have the ack script use that if no file path is provided
* Work on search for web view text, because of how this relates to bullets
* Auto quit
* Experiment with converting bullets to CoffeeScript, then working on it adding features for both Search, Markdown, and Git
* Plugin todos for file, auto open the same files on next run?
* Multiple options selection for a plugin, e.g., if multiple file extensions accept a plugin, show a menu. I want to be able to associate Markdown files this way and provide either "Editor" or "Markdown"
