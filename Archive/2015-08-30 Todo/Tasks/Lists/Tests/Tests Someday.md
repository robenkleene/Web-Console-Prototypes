# Tests Someday

- If I can figure out a way to test if a process is running (E.g., use a new AppleScript API? "Plugin running tasks"?) then there are more useful tests to write here
- Crashes right now if the directory a script should run in is unreachable
- Test for invalid script, i.e., a blank script causes a crash right now
- Show output in a Web Console Plugin
	- Ruby Unit Test has a way to pass in a GUI? Use that API for Web Console as a gui?
		- You can use `--runner=gtk2` option to use GTK+ test runner
			- How do execute an entirely separate process of my app from the tests?
	- If I run two instances of the app via one of these methods, how does AppleScript determine which instance to send events to?
	
			/Applications/Safari.app/Contents/MacOS/Safari & open -n -b com.apple.Safari