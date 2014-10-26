# `NSFileCoordinator` Implementation

## Final Simple Implementation

The `PluginDataController` just watches the plugin folders, when it sees a change involving an `Info.plist` it:

1. Removes any existing plugin for that path.
2. Loads the plugin.

## Ideas

I'll want to make all file system access conform to `NSFileCoordinator` APIs. These will need tests.

## Todo

* Watch the `Info.plist` if it changes reload the plugin.
* Watch the `Contents/Resources` folder, if it moves, invalidate the plugin. If another `Resources` folder gets moved back it its place, re-validate the plugin.
* Add validation that a `Contents/Resources` plugin must be present.

### Tests

* Make an edit to the plugin that invalidates it
* Move the `Info.plist`

## Implementation

### Rules

The problem with below is once a plugin becomes in valid, the `PluginDataController` will invalidate it, and therefore the plugin `Info.plist` and `Resources` directory will no longer be watched, so the plugin won't be reloaded if it becomes valid again.

* If the `Info.plist` file moves, invalidate the plugin
* If the `Contents/Resources` folder moves, invalidate the plugin
* If the `Info.plist` file is edited reload the plugin (this should exclude edits made in the plugin editor)
* If a new file moves into the `Info.plist` location, reload the plugin 
* If a new folder moves into the `Contents/Resources` folder, reload the plugin

### Rules Attempt 2

The problem with below, is that relatively little value is added for the complexity of watching the `Contents/Resources` folder. Perhaps a better solution can be had by just watching two locations: plugin folder locations, and the `Info.plist` for all directories.

The `PluginDataController` watches:
    1. All plugin folder locations
    2. In each plugin folder, the `Info.plist` and `Contents/Resources` folders

* If the `Info.plist` changes, the plugin is reloaded.
* If the `Contents/Resources` folder or the `Info.plist` move, invalidate the plugin.
* If any change happens inside a folder for an invalid plugin, attempt to reload it.

### Rules Attempt 3

The `PluginDataController` watches:

1. All plugin folder locations
2. The `Info.plist` in each folder location
    * If it doesn't exist, the container folder for the `Info.plist`

For edits the `Info.plist` is more appropriately handled by the plugin itself, because it is in a better position to manage pending edits to the `Info.plist`.

#### Simple Delegation of Responsibility

* The `PluginDataController` is responsible for anything that adds or removes a plugin.
* The `Plugin` is responsible for any edits to the `Info.plist`.


#### Handling the `Contents/Resources` Location

Just punt this for now.

### Class Structures

* `PluginFilePresentationManager`

* `PluginFilePresentationManagerDelegate`
    * `PluginFilePresentationManagerDelegate:managedFileDidMove:`

### `WCLPluginDataController`

* The `WCLPluginDataController` watches the plugin directory, removes plugins when they are removed from the plugin directories and adds them when they are added.

#### Solitary Plugins

* Solitary plugins don't need any custom logic because they should stay loaded even if their path changes, and the rest of the `WCLPluginDataController` API doesn't need to be implemented for solitary plugins.

### `WCLPlugin`

The `WCLPlugin` needs to handle a few things:

* If the `Contents/Info.plist` changes, the values should be reloaded
* If the directory structure changes, e.g., the following paths must remain standard:

        <PluginName>.wclplugin/
            Contents/
                Resources/
                    <command>
                Info.plist
    
* The `Command` must be executable

For now it seems like the only thing I need to watch is the `Info.plist`, then if it changes reload the plugin, probably invalidating it until it is successfully reloaded.

I don't see any reason to watch the whole plugin directory, the only things I really care about are the `Info.plist` and the executable.

### Writing Tests

* How do I write tests for `NSFileCoordinator` APIs?
  * E.g., have an `NSFileManager` do a `coordinateWritingItemAtURL:` on a file being presented. This should trigger a `presentedSubitemDidChangeAtURL:` notification.
* Test `accommodatePresentedItemDeletionWithCompletionHandler:`. E.g., open a plugin, then delete it from the file system. It should receive a `accommodatePresentedItemDeletionWithCompletionHandler:` telling the item to be deleted.

## Notes

### Deleting Presented Items

`accommodatePresentedItemDeletionWithCompletionHandler:` should be called when an item is about to be deleted.

### Writing a New File with NSFileCoordinator

``` objective-c
- (BOOL)saveAndReturnError:(NSError **)outError {
    NSURL *url = [self url];
    __block BOOL didWrite = NO;
    NSFileCoordinator* fc = [[NSFileCoordinator alloc]
                                initWithFilePresenter:self];
    [fc coordinateWritingItemAtURL:url
                           options:NSFileCoordinatorWritingForReplacing
                             error:outError
                        byAccessor:^(NSURL *updatedURL) {
        NSFileWrapper *fw = [self fileWrapper];
        didWrite = [fw writeToURL:updatedURL options:0
              originalContentsURL:nil error:outError];
    }];
    return didWrite;
}
//*
```

### Summary

* Use `NSFileCoordinator` when you read and write files
* Use `NSFilePresenter` to hear about changes that happened
* Use `NSFileVersion` to deal with conflicts
