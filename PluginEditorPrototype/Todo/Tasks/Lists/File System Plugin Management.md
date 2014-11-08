# File System Plugin Management

## Todo

* Refactor `PluginTests`:
    * Make `TemporaryPluginTestCase`
        * Then create two subclasses:
            1. The existing `testRenamePluginDirectory`, this should now be a test I'll use later to test that a plugin managed by a `PluginDirectoryManager` has it's paths properly updated after being moved
            2. New `PluginDirectoryManagerTests` that assure that when a plugin directory changes that the appropriate callbacks fire from the `PluginDirectoryManager`

* Refactor the `testRenamePluginDirectory` test
    * This should now be a `PluginDirectoryManager` test
    * After moving the plugin, test that the `PluginDirectoryManager` callbacks fire
* Review `TODO: EXTENSION BEGIN`, perhaps these can be moved back to extensions now that the derived data has been deleted?

## Implementation Notes

Figure out a way to reconcile my goals for `testCopyPlugin`, with the current implementation that copies the plugin to the caches directory.

`testCopyPlugin` should instead be used as the basis for starting tests for the `PluginDirectoryManager`. The tests should make sure that the `PluginDirectoryManager` performs the correct callbacks when a plugin is moved.

* Research `NSFilePresenter` in iOS 8

### Implementation Steps

1. In the `EventsDemo` project, create a working example of the `PluginDirectoryManager`, and test that it performs the correct callbacks below. 
    * Test that editing the plugin in another application (e.g., BBEdit) works as expected.
    * But really it looks like the C APIs are going to be more viable.
2. Migrate the `PluginDirectoryManager` and the `testCopyPlugin` test from the `FileSystem` project into `PluginEditorPrototype`.
3. Start adapting the `testCopyPlugin` test into a test that the correct `PluginDirectoryManagerDelegate` delegate callbacks get called for the appropriate events.

## Implementation

The `PluginDataController` just watches the plugin folders, when it sees a change involving an `Info.plist` it:

1. Removes any existing plugin for that path.
2. Loads the plugin.

## Notes

Right now I have a test setup called `testCopyPlugin`, it creates a plugin in the caches directory:

    testPlugin.bundle.bundlePath = /Users/robenkleene/Library/Caches/PluginEditorPrototype/PluginCopy/F1F1317B-C13E-45DD-BFD2-BB2F07D2E3BC

### Potential Solution

The `PluginDataController` just watches the plugin directories, if a directory with the `.wcplugin` file extension gets added, it adds a `PluginDirectoryManager` to that directory. The `PluginDirectoryManager` watches for a `Contents/Info.plist`. If the `Info.plist` gets added, it sends a delegate message that says `pluginDirectoryManager:fileDidUpdate:` if it moves, `pluginDirectoryManager:fileDidMove:`.

1. Moving an `Info.plist` should only invalidate the plugin if it was moved from a plugin directory (in order for manually loaded plugins to be moved without them being unloaded).

### `NSFilePresenter` Code

	NSFileCoordinator.addFilePresenter(self)


    // MARK: - NSFilePresenter
    
    var presentedItemURL: NSURL? {
        get {
            return self.bundle.bundleURL
        }
    }
    
    var presentedItemOperationQueue: NSOperationQueue {
        return NSOperationQueue.mainQueue()
    }

## Design

* `PluginManager: PluginDataControllerDelegate`
    * `unloadPlugin(_ plugin: Plugin)`
    * `loadPlugin(_ plugin: Plugin)`
* `PluginDataControllerDelegate`
    * `pluginDataController(_ pluginDataController: PluginDataController, pluginDidBecomeInvalid: Plugin)`
    * `pluginDataController(_ pluginDataController: PluginDataController, pluginDidBecomeValid: Plugin)`
* `PluginDataController: PluginDirectoryManager`
* `PluginDirectoryManagerDelegate`
    * `pluginDirectoryManager(_ pluginDirectoryManager: PluginDirectoryManager, itemWillMoveFromURL fromURL: NSURL, toURL: NSURL)`
    * `pluginDirectoryManager(_ pluginDirectoryManager: PluginDirectoryManager, itemDidMoveFromURL fromURL: NSURL, toURL: NSURL)`
    * `pluginDirectoryManager(_ pluginDirectoryManager: PluginDirectoryManager, itemWillChangeAtURL url: NSURL)`
    * `pluginDirectoryManager(_ pluginDirectoryManager: PluginDirectoryManager, itemDidChangeAtURL url: NSURL)`

### `PluginDataController` Handling `PluginDirectoryManagerDelegate` Messages 

#### Will Change

1. If an item will move out of a plugin directory, unload the `Plugin`, and the `PluginDirectoryManager`
2. If the `Info.plist` will change, unload the plugin, and keep the `PluginDirectoryManager`
3. If the `Info.plist` will move, unload the plugin, and keep the `PluginDirectoryManager`

#### Did Change

1. If the item did move into a plugin directory, load the plugin and create a `PluginDirectoryManager` if one doesn't already exist
2. If the `Info.plist` did move, reload the plugin
3. If the `Info.plist` did change, reload the plugin
