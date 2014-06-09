# NSArrayController and Adding and Removing

## Cases to handle

1. User adds a plugin by opening a `wcplugin` bundle.
2. User adds a plugin by adding it to the file system.
3. User removes a plugin by deleting it from the file system.

## User adds a plugin by opening a `wcplugin` bundle.

1. The application calls 'addedPluginAtURL' on the `WCLPluginManager`.
2. The `WCLPluginManager` passes on the creation of the plugin object from the file URL to the `WCLPluginDataController`.
3. The `WCLPluginDataController` creates the plugin object from the bundle at the URL and posts a "plugin was added" notification containing the new plugin.
4. The `WCLPluginManager` observes the notification and handles it by adding the plugin to its "name to plugin" mapping.
5. The `WCLPluginManagerController` observes the notification and handles it by adding the plugin to its array.

## User adds a plugin by adding it to the file system.

1. The `WCLPluginDataController` observes the file system change and creates the plugin object and posts a "plugin was added" notification containing the new plugin.
2. Steps 4-5 above happen

## 3. User removes a plugin by deleting it from the file system.

1. The `WCLPluginDataController` observes the file system change and posts a "plugin was removed" notification containing the deleted plugin (how would it know which plugin was removed?).
  - The `WCLPluginDataController` is going to have to manage an data structure to map file system changes to individual plugins.
2. The `WCLPluginManager` observes the notification and handles it by removing the plugin from its "name to plugin" mapping.
3. The `WCLPluginManagerController` observes the notification and handles it by removing the plugin from its array.
