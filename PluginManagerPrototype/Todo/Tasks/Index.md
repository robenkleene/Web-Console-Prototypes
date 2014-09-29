# Index

## `plist` Backed Plugins

* [ ] Each time a bundle moves its path needs to be updated
	* Can this be implemented with file system watching?
* [ ] Make a logger that logs to console?
	* Add can be overridden to suppress logs while running tests
	* Ideally it can also confirm that the call happened? Probably not worth it
* [ ] Expect the log message to be called
* [ ] Figure out how to `spyOn` methods to prevent logging noise
* [ ] Test plugin name and identifier save
	* [ ] Make sure KVO works for this? 
* [ ] Write the reverse, so the plugin and identifier changes can be propagated up
	* Make sure KVO works for this?
* [ ] Prevent invalid filenames from being valid plugin names
	* Test that an invalid filename isn't returned as a valid plugin name (use `fileURLWithPath`)
* [ ] Make it so if the plugin's plist is moved out from under it, the plugin becomes invalid
	* Write tests for this
* [ ] Make sure built-in plugins are not writable/editable
* [ ] Then write tests for it
* [ ] Then use that method to test the copy and cleanup stuff
* [ ] Test new caches path
* [ ] The plugin data controller should watch the plugin path
* [ ] Add deleting on start up and tests for it
	* Recreating a directory should work afterwords
* [ ] Consolidate directory tests
* [ ] Get a proper caches folder ready
* [ ] Build functionality around cleaning up the temp directory and then asserting if it had to clean up
	* Can force this by setting break point in a test, which will leave a left over temp directory
* [ ] Can I do nested test cases?
	* Only one of my cases needs the temporary directory
* [ ] Do test where I load plugins from multiple paths
	* It should return twice as many plugin paths but half as many plugins
	* This isn't a great test, instead its better to have two separate directories
	* Write this test after I have a way to create temporary plugin
* [ ] Abstract the nameToPluginController to nameToObjectController
* [ ] Key to object controller
* [ ] First write `- (WCLPlugin *)newPluginFromPlugin:(WCLPlugin *)plugin`
	* This should copy the bundles resources to the new bundle location
* [ ] Then use the above to create a bundle in a temporary location, that I can then use that bundle to test the read write methods
	* Use `NSCachesDirectory` as the temporary location?
* [ ] For now this will just copy without doing anything fancy, once I have editable properties, I can start making the plugin be a subclass of `WCLPlugin`

### Class Design

* Plugin
	* *has a* bundle

### Tests

- Confirm that the text of the plist is the same before and after a write

### Resources

* [mikeash.com: Friday Q&A 2013-08-30: Model Serialization With Property Lists](https://www.mikeash.com/pyblog/friday-qa-2013-08-30-model-serialization-with-property-lists.html)
