# File System Plugin Management

## Todo

* Refactor the `testRenamePluginDirectory` test
    * This should now be a `PluginDirectoryManager` test
    * After moving the plugin, test that the `PluginDirectoryManager` callbacks fire
* Review `TODO: EXTENSION BEGIN`, perhaps these can be moved back to extensions now that the derived data has been deleted?

## Implementation

The `PluginDataController` just watches the plugin folders, when it sees a change involving an `Info.plist` it:

1. Removes any existing plugin for that path.
2. Loads the plugin.

The `PluginDataController` just watches the plugin directories, if a directory with the `.wcplugin` file extension gets added, it adds a `PluginDirectoryManager` to that directory. The `PluginDirectoryManager` watches for a `Contents/Info.plist`. If the `Info.plist` gets added, it sends a delegate message that says `pluginDirectoryManager:fileDidUpdate:` if it moves, `pluginDirectoryManager:fileDidMove:`.

Moving an `Info.plist` should only invalidate the plugin if it was moved from a plugin directory (in order for manually loaded plugins to be moved without them being unloaded).

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
