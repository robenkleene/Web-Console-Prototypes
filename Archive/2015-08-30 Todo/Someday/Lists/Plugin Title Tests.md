# Plugin Title Tests

* [ ] Do a JavaScript version of the title test (on the print plugin)
* [ ] Make sure Print plugin is populating its title from the plugin name key
* [ ] When I add the plugin name environment variable for title, make sure it gets tested in the Xcode tests, because those tests won't exist anywhere else

## Notes

    def title
      return ENV.has_key?(WebConsole::PLUGIN_NAME_KEY)? ENV[WebConsole::PLUGIN_NAME_KEY] : "Dependencies"
    end
