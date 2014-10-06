# File System Prototype

* [ ] Setup a Plugin test
	* The test starts up and has a plugin loaded in the temporary folder

## The Three Methods of Watching the File System

* `kqueue`
* `FSEvents`: e.g., `FSEventStreamCreate`
* `NSFileCoordinator`
* `NSFilePresenter`

## How does TextEdit auto-update when it's file changes on disk?

`NSDocument` has a callback:

	func revertToContentsOfURL(_ absoluteURL: NSURL!, ofType typeName: String!, error outError: NSErrorPointer) -> Bool

`NSFileCooredinator` calls the above:

	func coordinateReadingItemAtURL(_ url: NSURL, options options: NSFileCoordinatorReadingOptions, error outError: NSErrorPointer, byAccessor reader: (NSURL!) -> Void)

### Backtrace

	* thread #1: tid = 0x2c25cb, 0x0000000100008dc7 TextEdit`-[DocumentWindowController setupTextViewForDocument](self=0x00006180000cc7f0, _cmd=0x0000000100023983) + 39 at DocumentWindowController.m:237, queue = 'com.apple.main-thread', stop reason = breakpoint 1.1
	  * frame #0: 0x0000000100008dc7 TextEdit`-[DocumentWindowController setupTextViewForDocument](self=0x00006180000cc7f0, _cmd=0x0000000100023983) + 39 at DocumentWindowController.m:237
		frame #1: 0x00007fff92c61cd0 CoreFoundation`-[NSArray makeObjectsPerformSelector:] + 480
		frame #2: 0x00000001000150ac TextEdit`-[Document revertToContentsOfURL:ofType:error:](self=0x0000000100511790, _cmd=0x00007fff90f8822a, url=0x0000610000074100, type=0x00007fff7d0871e0, outError=0x00007fff5fbfdde0) + 300 at Document.m:809
		frame #3: 0x00007fff9099b86c AppKit`-[NSDocument _revertToContentsOfURL:ofType:error:] + 60
		frame #4: 0x00007fff9099c2bb AppKit`__53-[NSDocument _revertToVersion:preservingFirst:error:]_block_invoke798 + 178
		frame #5: 0x00007fff925f4294 Foundation`-[NSFileCoordinator _invokeAccessor:thenCompletionHandler:] + 126
		frame #6: 0x00007fff925f4202 Foundation`__73-[NSFileCoordinator coordinateReadingItemAtURL:options:error:byAccessor:]_block_invoke + 118
		frame #7: 0x00007fff925f4174 Foundation`__85-[NSFileCoordinator(NSPrivate) _coordinateReadingItemAtURL:options:error:byAccessor:]_block_invoke264 + 125
		frame #8: 0x00007fff925f40d9 Foundation`-[NSFileCoordinator(NSPrivate) _invokeAccessor:orDont:thenRelinquishAccessClaimForID:] + 224
		frame #9: 0x00007fff925f2828 Foundation`-[NSFileCoordinator(NSPrivate) _coordinateReadingItemAtURL:options:error:byAccessor:] + 815
		frame #10: 0x00007fff925f24dd Foundation`-[NSFileCoordinator coordinateReadingItemAtURL:options:error:byAccessor:] + 129
		frame #11: 0x00007fff9099bf72 AppKit`__53-[NSDocument _revertToVersion:preservingFirst:error:]_block_invoke + 392
		frame #12: 0x00007fff9099a7d3 AppKit`-[NSDocument performSynchronousFileAccessUsingBlock:] + 42
		frame #13: 0x00007fff9099bdaa AppKit`-[NSDocument _revertToVersion:preservingFirst:error:] + 183
		frame #14: 0x00007fff909d345d AppKit`__46-[NSDocument relinquishPresentedItemToWriter:]_block_invoke_4 + 52
		frame #15: 0x00007fff90999955 AppKit`-[NSDocument continueFileAccessUsingBlock:] + 234
		frame #16: 0x00007fff909d3341 AppKit`__46-[NSDocument relinquishPresentedItemToWriter:]_block_invoke_3 + 274
		frame #17: 0x00007fff909ea0d2 AppKit`__62-[NSDocumentController(NSInternal) _onMainThreadInvokeWorker:]_block_invoke1807 + 175
		frame #18: 0x00007fff92c4c48c CoreFoundation`__CFRUNLOOP_IS_CALLING_OUT_TO_A_BLOCK__ + 12
		frame #19: 0x00007fff92c3dae5 CoreFoundation`__CFRunLoopDoBlocks + 341
		frame #20: 0x00007fff92c3d86e CoreFoundation`__CFRunLoopRun + 1982
		frame #21: 0x00007fff92c3ce75 CoreFoundation`CFRunLoopRunSpecific + 309
		frame #22: 0x00007fff9959ba0d HIToolbox`RunCurrentEventLoopInMode + 226
		frame #23: 0x00007fff9959b7b7 HIToolbox`ReceiveNextEventCommon + 479
		frame #24: 0x00007fff9959b5bc HIToolbox`_BlockUntilNextEventMatchingListInModeWithFilter + 65
		frame #25: 0x00007fff9052e24e AppKit`_DPSNextEvent + 1434
		frame #26: 0x00007fff9052d89b AppKit`-[NSApplication nextEventMatchingMask:untilDate:inMode:dequeue:] + 122
		frame #27: 0x00007fff9052199c AppKit`-[NSApplication run] + 553
		frame #28: 0x00007fff9050c783 AppKit`NSApplicationMain + 940
		frame #29: 0x0000000100001df2 TextEdit`main(argc=3, argv=0x00007fff5fbff720) + 34 at Edit_main.m:53
		frame #30: 0x00007fff97c3a5fd libdyld.dylib`start + 1

## Resources

[File System Programming Guide: The Role of File Coordinators and Presenters](https://developer.apple.com/library/mac/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileCoordinators/FileCoordinators.html):

> Using NSDocument and UIDocument to Handle File Coordinators and Presenters
>
> The UIDocument class on iOS and the NSDocument class on OS X encapsulate the data for a user document. These classes automatically support:
>
> The NSFileCoordinator implementation.
> The NSFilePresenter implementation.
> The Autosave implementation.
> Whenever possible you should explore using these classes to store your user data. Your app need only work directly with file coordinators and file presenters when dealing with files other than the user’s data files.
>
> Apps that use the document classes don’t need to worry about using file coordinators when reading and writing private files in the Application Support, Cache, or temporary directories, as these should be considered private.

[ios5 - What is the proper way to move a UIDocument to a new location on the file-system - Stack Overflow](http://stackoverflow.com/questions/8284137/what-is-the-proper-way-to-move-a-uidocument-to-a-new-location-on-the-file-system):

> For moving: move your file using NSFileCoordinator, inside the coordinator's block, call
>
> 	[fileCoordinator itemAtURL:URL willMoveToURL:toURL];
> 	[fileManager moveItemAtURL:newURL toURL:toURL error:&moveError];
> 	[fileCoordinator itemAtURL:URL didMoveToURL:toURL];
