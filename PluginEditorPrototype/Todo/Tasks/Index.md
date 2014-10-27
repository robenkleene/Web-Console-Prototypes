# Index

## Todo

* Move over the `testRenamePluginDirectory` test for FileSystem tests
* Start creating `PluginDataController` that implements `NSFilePresenter`
* Make sure the all the `didSet` for plugin setters don't get called during initialization

### Plugin Changes

* [ ] Remove all managed object context stuff from the main project
* [ ] Instead make those plugins `plist` based
	* Plugins should not be editable by default
* [ ] Figure out how to managed editable vs. un-editable plugins

## Notes

### Moving over the `testRenamePluginDirectory` Test

This test takes a temporary plugin, moves it, and then confirms that its `commandPath` is still accessible. Right now it isn't because once the 
