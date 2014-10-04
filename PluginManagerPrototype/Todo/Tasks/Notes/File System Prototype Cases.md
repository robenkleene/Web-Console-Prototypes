# File System Prototype

* Create external processes (e.g., by running script) and confirm that the appropriate events happen

## Cases

### A plugin's folder gets renamed

The plugin's bundle should reload.

1. Detect the file system change
2. Reload the bundle

### A plugin gets added to a plugin folder

The plugin should be added.
	
1. Detect the newly added directory
2. Load the plugin, but only if the plugin isn't already loaded, otherwise the plugin will loads itself (per a plugin's folder gets renamed).

### A plugin gets removed from a plugin folder

1. Detect the removed plugin
2. The plugin should be unloaded
3. The plugin should no longer watch itself

### A plugin's folder gets renamed in a plugin folder

1. Detect the newly added directory
2. Detect the file system change
3. The plugin should be reloaded, but whose responsibility should this be?
