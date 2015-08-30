# Automatic Termination

My implementation is incredibly simple, disable with an open window running. I probably don't even have to do this, just mark all windows as not restorable and done.



I could also disable when there is a running process and if there is a window, then save and restore it's state?

Simpler implementation, but this will also quit the app if it's the frontmost application

[objective c - How to quit cocoa app when windows close? - Stack Overflow](http://stackoverflow.com/questions/5268757/how-to-quit-cocoa-app-when-windows-close)

## Implementation

For windows

	[window setRestorable:YES]

Disable

	[NSProcessInfo processInfo] disableAutomaticTermination:@"Reason"];

Re-enable

	[NSProcessInfo processInfo] enableAutomaticTermination:@”Reason”];

Set the key “NSSupportsAutomaticTermination” in your Info.plist 

	<key>NSSupportsAutomaticTermination</key>
	<true/>

Or use NSProcessInfo

	[[NSProcessInfo processInfo] setAutomaticTerminationSupportEnabled: YES];

## Notes

[Mac App Programming Guide: The Core App Design](https://developer.apple.com/library/mac/documentation/General/Conceptual/MOSXAppProgrammingGuide/CoreAppDesign/CoreAppDesign.html#//apple_ref/doc/uid/TP40010543-CH3-SW27):

> Automatic termination eliminates the need for users to quit an app. Instead, the system manages app termination transparently behind the scenes, terminating apps that are not in use to reclaim needed resources such as memory.

> Sudden termination allows the system to kill an app’s process immediately without waiting for it to perform any final actions. The system uses this technique to improve the speed of operations such as logging out of, restarting, or shutting down the computer.

- [Automatic Termination](https://developer.apple.com/library/mac/documentation/General/Conceptual/MOSXAppProgrammingGuide/CoreAppDesign/CoreAppDesign.html#//apple_ref/doc/uid/TP40010543-CH3-SW27)
- [Sudden Termination](https://developer.apple.com/library/mac/documentation/General/Conceptual/MOSXAppProgrammingGuide/CoreAppDesign/CoreAppDesign.html#//apple_ref/doc/uid/TP40010543-CH3-SW28)
