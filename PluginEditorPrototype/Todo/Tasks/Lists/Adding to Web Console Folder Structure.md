# Web Console Folder Structure Work

For the next step, organize test targets based on their dependencies.

## Goals

* It should be easy to run all tests that don't involve UI (and are therefore faster)
* Test targets should be organized based on their dependencies, i.e., all the tests that need the `WCLTaskTestsHelper` should be in the same target as that file, and tests that don't need it should not.

## App

* General
	* `WCLAppDelegate.h`
	* `WCLAppDelegate.m`
	* `WCLUserInterfaceTextHelper.h`
	* `WCLUserInterfaceTextHelper.m`
	* `WCLWebConsoleConstants.h`
* Web Windows
	* `WCLWebWindowController.h`
	* `WCLWebWindowController.m`
	* `WCLWebWindowsController.h`
	* `WCLWebWindowsController.m`
* Preferences
	* `WCLEnvironmentViewController.h`
	* `WCLEnvironmentViewController.m`
	* `WCLPluginManagerController.h`
	* `WCLPluginManagerController.m`
	* `WCLFileExtension.h`
	* `WCLFileExtension.m`
	* `WCLFilesViewController.h`
	* `WCLFilesViewController.m`
	* `WCLPluginViewController.h`
	* `WCLPluginViewController.m`
	* `WCLPreferencesWindowController.h`
	* `WCLPreferencesWindowController.m`
	* `WCLFileExtensionController.h`
	* `WCLFileExtensionController.m`
	* `WCLEnvironmentViewController.xib`
	* `WCLFilesViewController.xib`
	* `WCLPluginViewController.xib`
	* `WCLPreferencesWindowController.xib`
* AppleScript
	* `NSApplication+AppleScript.h`
	* `NSApplication+AppleScript.m`
	* `WCLLoadHTMLScriptCommand.h`
	* `WCLLoadHTMLScriptCommand.m`
	* `WCLDoJavaScriptCommand.h`
	* `WCLDoJavaScriptCommand.m`
* Plugins
	* `WCLPlugin.h`
	* `WCLPlugin.m`
	* `WCLPlugin+Validation.h`
	* `WCLPlugin+Validation.m`
	* `WCLPluginManager.h`
	* `WCLPluginManager.m`
	* `WCLPluginTask.h`
	* `WCLPluginTask.m`
	* `WCLPluginDataController.h`
	* `WCLPluginDataController.m`
	* `WCLNameToPluginController.h`
	* `WCLNameToPluginController.m`
* Tasks
	* `NSTask+Termination.h`
	* `NSTask+Termination.m`
	* `WCLApplicationTerminationHelper.h`
	* `WCLApplicationTerminationHelper.m`
	* `WCLTaskHelper.h`
	* `WCLTaskHelper.m`

## Tests

* `Web ConsoleTests`
	* `WCLPlugin+Tests.h`
	* `WCLPluginTests.m`
	* `WCLTaskTestsHelper.h`
	* `WCLTaskTestsHelper.m`
	* `WCLPreferencesWindowControllerTests.m`
	* `NSRectHelpers.h`
	* `Web_ConsoleTestsConstants.h`
	* `XCTest+BundleResources.h`
	* `XCTest+BundleResources.m`
* `WebWindowTests`
	* `WCLWebWindowControllerHTMLTests.m`
	* `WCLWebWindowControllerResizingTests.m`
	* `WCLWebWindowControllerTaskTests.m`
	* `WCLWebWindowControllerTestCase.h`
	* `WCLWebWindowControllerTestCase.m`
	* `WCLWebWindowControllerTestsHelper.h`
	* `WCLWebWindowControllerTestsHelper.m`
* `TestPluginManagerTests`
	* `WCLFileExtensionTests.m`
	* `WCLFileExtensionsControllerTests.m`
	* `WCLKeyValueObservingTestsHelper.h`
	* `WCLKeyValueObservingTestsHelper.m`
	* `WCLPluginManager+TestPluginManager.h`
	* `WCLPluginManager+TestPluginManager.m`
	* `WCLPluginManagerDefaultNewPluginTests.m`
	* `WCLPluginManagerTests.m`
	* `WCLTestPluginManager.h`
	* `WCLTestPluginManager.m`
	* `WCLTestPluginManagerTestCase.h`
	* `WCLTestPluginManagerTestCase.m`
