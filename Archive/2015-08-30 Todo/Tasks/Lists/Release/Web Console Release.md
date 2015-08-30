# Web Console Release

* [ ] If process exits with error code display error message in popup?
* [ ] Log all `NSLog` messages to the console?
	* Looks like they are already being logged there, clean them up?
* [ ] General Preferences
	* General Preference to set whether opened plugins are added to "Web Console" permanently or loaded for this session only (or just run)? (Holding option should perform the opposite)
	* General Preference to select theme
* [ ] Deal with all menu options
* [ ] Documentation Plugin
* [ ] Default Plugin "Demo": Says you can script this window by doing X, Y, Z this is default when making a new window
* [ ] Review nextKeyView on Preference Panes
* [ ] What should opening a plugin do?
	* Probably need to give plugins an extensions for open behavior?
	* Present a dialog to either load the bundle, or add it to Plugins? The default behavior is probably to add it, hold option for the reverse.
		* Perhaps which is the default can be defined on the plugin
* [ ] Code Signing
* [ ] Preferences UI Refinements
	* Windows should be fixed height
	* Figure out a default height for the two table views
	* Place the add/subtract buttons correctly relative to the table view
