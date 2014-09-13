require 'webconsole'
require WebConsole::shared_resource("ruby/wcrepl/wcrepl")
require File.join(File.dirname(__FILE__), "constants")

module WcNode
  class Wrapper < WcREPL::Wrapper
    require INPUT_CONTROLLER_FILE
    require OUTPUT_CONTROLLER_FILE
    require WINDOW_MANAGER_FILE

    def initialize
      super("node")
    end

    def parse_input(input)
      input.gsub!("\uFF00", "\n") # \uFF00 is the unicode character Coffee uses for new lines, it's used here just to consolidate code into one line
      super(input)
    end

    def write_input(input)
      input = input.dup
      input.gsub!("\t", "\s\s") # Replace tabs with spaces
      super(input)
    end

    def output_controller
      if !@output_controller
        @output_controller = WcNode::OutputController.new(window_manager)
      end
      return @output_controller
    end

    def input_controller
      if !@input_controller
        @input_controller = WcNode::InputController.new(window_manager)
      end
      return @input_controller
    end

    def window_manager
      if !@window_manager
        @window_manager = WcNode::WindowManager.new
      end
      return @window_manager
    end    
  end
  
end