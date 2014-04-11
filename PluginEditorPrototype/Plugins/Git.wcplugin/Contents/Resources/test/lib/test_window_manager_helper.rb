require 'webconsole'

module WcGit
  module Tests
    class WindowManagerHelper

      COFFEESCRIPT_DIRECTORY = File.join(File.dirname(__FILE__), "..", "coffee")
      TESTHELPER_COFFEESCRIPT_FILE = File.join(COFFEESCRIPT_DIRECTORY, "test_helper.coffee")
      def initialize(window_manager)
        @window_manager = window_manager

        coffeescript = File.read(TESTHELPER_COFFEESCRIPT_FILE)
        @window_manager.do_coffeescript(coffeescript)
      end

      def element_count_for_selector(selector)
        coffeescript = "return wcTestHelper.elementCount('#{selector}')"
        return @window_manager.do_coffeescript(coffeescript)
      end
    end
  end
end