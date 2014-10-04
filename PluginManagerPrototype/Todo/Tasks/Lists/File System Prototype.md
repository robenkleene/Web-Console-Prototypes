# File System Prototype

* [ ] Setup a Plugin test
	* The test starts up and has a plugin loaded in the temporary folder

## How does TextEdit auto-update when it's file changes on disk?

`NSDocument` has a callback:

	func revertToContentsOfURL(_ absoluteURL: NSURL!, ofType typeName: String!, error outError: NSErrorPointer) -> Bool

`NSFileCooredinator` calls the above:

	func coordinateReadingItemAtURL(_ url: NSURL, options options: NSFileCoordinatorReadingOptions, error outError: NSErrorPointer, byAccessor reader: (NSURL!) -> Void)