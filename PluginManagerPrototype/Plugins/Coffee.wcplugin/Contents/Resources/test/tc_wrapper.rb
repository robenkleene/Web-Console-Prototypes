#!/usr/bin/env ruby

require "test/unit"
require "webconsole"

require WebConsole::shared_test_resource("ruby/test_constants")
require WebConsole::Tests::TEST_HELPER_FILE

TEST_CONSTANTS_FILE = File.join(File.dirname(__FILE__), 'lib', 'test_constants')
require TEST_CONSTANTS_FILE

require WRAPPER_FILE

class TestWrapper < Test::Unit::TestCase
  def test_wrapper
    wrapper = WcCoffee::Wrapper.new

    test_text = %Q[add = (x, y)->
      x + y
add(1, 2)]
    test_result = "3"

    wrapper.parse_input(test_text.gsub("\n", "\uFF00") + "\n")

    sleep WebConsole::Tests::TEST_PAUSE_TIME # Pause for output to be processed

    window_id = WebConsole::Tests::Helper::window_id
    window_manager = WebConsole::WindowManager.new(window_id)
    
    # Test Wrapper Input
    javascript = File.read(WebConsole::Tests::FIRSTCODE_JAVASCRIPT_FILE)
    result = window_manager.do_javascript(javascript)
    result.strip!
    result.gsub!(/<\/?span.*?>/, "") # Remove spans adding by highlight.js
    result.gsub!("&gt;", ">") # Unescape entity
    assert_equal(test_text, result, "The test text should equal the result.")
    
    # Test Wrapper Output
    javascript = File.read(WebConsole::Tests::LASTCODE_JAVASCRIPT_FILE)
    result = window_manager.do_javascript(javascript)
    result.strip!
    assert_equal(result, test_result, "The test result should equal the result.")
    
    window_manager.close
  end

end
