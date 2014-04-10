#!/usr/bin/env ruby

require "test/unit"
require "webconsole"

require WebConsole::shared_test_resource("ruby/test_constants")
TEST_CONSTANTS_FILE = File.join(File.dirname(__FILE__), 'lib', 'test_constants')
require TEST_CONSTANTS_FILE

require INPUT_CONTROLLER_FILE
require WINDOW_MANAGER_FILE
require OUTPUT_CONTROLLER_FILE

class TestOutputController < Test::Unit::TestCase
  
  def setup
    @window_manager = WcREPL::WindowManager.new
    WcREPL::InputController.new(@window_manager) # Just to get the window_manager loaded with resources
    @output_controller = WcREPL::OutputController.new(@window_manager)
  end
  
  def teardown
    @window_manager.close
  end

  def test_output_controller
    test_text = "Some test text"
    @output_controller.parse_output(test_text)
    
    javascript = File.read(WebConsole::Tests::LASTCODE_JAVASCRIPT_FILE)
    result = @window_manager.do_javascript(javascript)
    result.strip!

    assert_equal(test_text, result, "The test text should equal the result.")
  end

  def test_remove_escape_sequence
    test_text = "Some test text"
    @output_controller.parse_output("\x1b0000m" + test_text)
    
    javascript = File.read(WebConsole::Tests::LASTCODE_JAVASCRIPT_FILE)
    result = @window_manager.do_javascript(javascript)
    result.strip!

    assert_equal(test_text, result, "The test text should equal the result.")
  end
end