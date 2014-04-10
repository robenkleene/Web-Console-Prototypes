#!/usr/bin/env ruby

require "test/unit"
require "webconsole"

require WebConsole::shared_test_resource("ruby/test_constants")
TEST_CONSTANTS_FILE = File.join(File.dirname(__FILE__), 'lib', 'test_constants')
require TEST_CONSTANTS_FILE

require INPUT_CONTROLLER_FILE
require WINDOW_MANAGER_FILE

class TestInputController < Test::Unit::TestCase

  def test_input_controller
    window_manager = WcREPL::WindowManager.new
    input_controller = WcREPL::InputController.new(window_manager)
    
    test_text = "Some test text"
    input_controller.parse_input(test_text)
    
    javascript = File.read(WebConsole::Tests::LASTCODE_JAVASCRIPT_FILE)
    result = window_manager.do_javascript(javascript)
    result.strip!

    assert_equal(test_text, result, "The test text should equal the result.")

    window_manager.close
  end

end