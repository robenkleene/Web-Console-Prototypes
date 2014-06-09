# Fixing Save Errors

## Cleaning Up Singleton Instances

- One instance of `sharedPluginManager` in `WCLFileExtension`

- Add note to design doc:
  - Only ViewControllers should ever access singletons via the `sharedPluginManager` because unit tests are only setup below the view layer right now

## Couple of Problems

1. I need to return a unique name before setting it, this means refactor out `renameWithUniqueName` to `uniquePluginNameFromName`
2. I'm calling my singleton in places I shouldn't review every instance of `sharedPluginManager` and make sure I call `[self pluginManager]` instead.
  - All the unique plugin name stuff should probably go into the pluginManager itself
    - If I do this, I can probably get rid of the `WCLPlugin (PluginManager)` category
      - No I can't, `nameIsValid` still needs this
