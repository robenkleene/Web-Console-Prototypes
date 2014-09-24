# Index

## `plist` Backed Plugins

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