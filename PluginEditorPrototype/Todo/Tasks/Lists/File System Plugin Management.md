# File System Plugin Management

## Todo

* Figure out a way to reconcile my goals for `testCopyPlugin`, with the current implementation that copies the plugin to the caches directory.

## Implementation

The `PluginDataController` just watches the plugin folders, when it sees a change involving an `Info.plist` it:

1. Removes any existing plugin for that path.
2. Loads the plugin.

## Notes

Right now I have a test setup called `testCopyPlugin`, it creates a plugin in the caches directory:

    testPlugin.bundle.bundlePath = /Users/robenkleene/Library/Caches/PluginEditorPrototype/PluginCopy/F1F1317B-C13E-45DD-BFD2-BB2F07D2E3BC

