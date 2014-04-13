# Index

Making the plugin editor work with a `WCLTestPlugin` that is not a `WCLPlugin` subclass.

* [ ] Memory Errors

		PluginEditorPrototype(33767,0x7fff75d88310) malloc: *** error for object 0x100104ae0: incorrect checksum for freed object - object was probably modified after being freed.
		*** set a breakpoint in malloc_error_break to debug

	* Google Search `XCTestCase` `NSZombieEnabled`
	* [unit testing - How can I run OCUnit (SenTestingKit) with NSDebugEnabled, NSZombieEnabled, MallocStackLogging? - Stack Overflow](http://stackoverflow.com/questions/3794287/how-can-i-run-ocunit-sentestingkit-with-nsdebugenabled-nszombieenabled-mallo)
* [ ] Get tests to pass
	* It appears that KVO for adding a file extension to a plugins file extensions isn't happening
	* Instances of `[WCLPlugin class]` are returning `NO`
* [ ] Transfer over `WCLPlugin` to `WCLTestPlugin`
	* Figure out solution for all the shared code here because I can't use inheritance?
		* Perhaps I can use swizzling for this?
	* Oy, all the methods in `WCLPlugin+Validation` too
* [ ] Remove all managed object context stuff from the main project
* [ ] Instead make those plugins `plist` based
	* Plugins should not be editable by default
* [ ] Figure out how to managed editable vs. un-editable plugins
