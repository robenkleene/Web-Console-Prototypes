require 'webconsole'
require WebConsole::shared_resource("ruby/wcrepl/wcrepl")
require File.join(File.dirname(__FILE__), "constants")

module WcCoffee
  class Wrapper < WcREPL::Wrapper
    require OUTPUT_CONTROLLER_FILE
    require INPUT_CONTROLLER_FILE
    require WINDOW_MANAGER_FILE

    def initialize
      super("coffee")
    end

    def write_input(input)
      input = input.dup
      input.gsub!("\t", "\s\s\s\s") # Coffee in pty handles spaces better than tabs
      super(input)
    end


    def input_controller
      if !@input_controller
        @input_controller = WcCoffee::InputController.new(window_manager)
      end
      return @input_controller
    end

    def output_controller
      if !@output_controller
        @output_controller = WcCoffee::OutputController.new(window_manager)
      end
      return @output_controller
    end
    
    def window_manager
      if !@window_manager
        @window_manager = WcCoffee::WindowManager.new
      end
      return @window_manager
    end    
  end
  
end