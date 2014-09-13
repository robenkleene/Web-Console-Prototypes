require 'webconsole'
require WebConsole::shared_resource("ruby/wcrepl/wcrepl")
require File.join(File.dirname(__FILE__), "constants")

module WcIRB
  class Wrapper < WcREPL::Wrapper
    require OUTPUT_CONTROLLER_FILE
    require INPUT_CONTROLLER_FILE
    require WINDOW_MANAGER_FILE

    def initialize
      super("irb")
    end

    def parse_input(input)
      input.gsub!("\uFF00", "\n") # \uFF00 is the unicode character Coffee uses for new lines, it's used here just to consolidate code into one line
      super(input)
    end

    def input_controller
      if !@input_controller
        @input_controller = WcIRB::InputController.new(window_manager)
      end
      return @input_controller
    end

    def output_controller
      if !@output_controller
        @output_controller = WcIRB::OutputController.new(window_manager)
      end
      return @output_controller
    end
    
    def window_manager
      if !@window_manager
        @window_manager = WcIRB::WindowManager.new
      end
      return @window_manager
    end    
  end
  
end