module WebConsole
  module Tests
    # General
    TEST_PAUSE_TIME = 0.5

    # Ruby
    TEST_RUBY_DIRECTORY = File.dirname(__FILE__)
    TEST_HELPER_FILE = File.join(File.dirname(__FILE__), "test_helper")

    # Plugins
    TEST_PLUGIN_DIRECTORY = File.join(File.dirname(__FILE__), "..", "plugin")
    HELLOWORLD_PLUGIN_FILE = File.join(TEST_PLUGIN_DIRECTORY, "HelloWorld.wcplugin")
    HELLOWORLD_PLUGIN_NAME = "HelloWorld"
    PRINT_PLUGIN_FILE = File.join(TEST_PLUGIN_DIRECTORY, "Print.wcplugin")
    PRINT_PLUGIN_NAME = "Print"

    # HTML
    TEST_HTML_DIRECTORY = File.join(File.dirname(__FILE__), "..", "html")
    INDEX_HTML_FILE = File.join(TEST_HTML_DIRECTORY, "index.html")
    INDEXJQUERY_HTML_FILE = File.join(TEST_HTML_DIRECTORY, "indexjquery.html")
    
    # JavaScript
    TEST_JAVASCRIPT_DIRECTORY = File.join(File.dirname(__FILE__), "..", "js")
    BODY_JAVASCRIPT_FILE = File.join(TEST_JAVASCRIPT_DIRECTORY, "body.js")
    BODYJQUERY_JAVASCRIPT_FILE = File.join(TEST_JAVASCRIPT_DIRECTORY, "bodyjquery.js")
    LASTCODE_JAVASCRIPT_FILE = File.join(TEST_JAVASCRIPT_DIRECTORY, "lastcode.js")
    FIRSTCODE_JAVASCRIPT_FILE = File.join(TEST_JAVASCRIPT_DIRECTORY, "firstcode.js")
    NODOM_JAVASCRIPT_FILE = File.join(TEST_JAVASCRIPT_DIRECTORY, "nodom.js")
    TEXT_JAVASCRIPT_FILE = File.join(TEST_JAVASCRIPT_DIRECTORY, "text.js")
    TEXTJQUERY_JAVASCRIPT_FILE = File.join(TEST_JAVASCRIPT_DIRECTORY, "textjquery.js")
  end
end