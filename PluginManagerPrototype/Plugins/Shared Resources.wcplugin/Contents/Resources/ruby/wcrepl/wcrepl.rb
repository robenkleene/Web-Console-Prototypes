module WcREPL
  require File.join(File.dirname(__FILE__), "lib", "constants.rb")
  require INPUT_CONTROLLER_FILE
  require OUTPUT_CONTROLLER_FILE
  require WINDOW_MANAGER_FILE

  class Wrapper
    require 'pty'
    def initialize(command)

      PTY.spawn(command) do |output, input, pid|
        Thread.new do
          output.each { |line|
            output_controller.parse_output(line)
          }
        end
        @input = input
      end
    end

    def parse_input(input)
      input_controller.parse_input(input)
      write_input(input)
    end

    def write_input(input)
      @input.write(input)
    end

    private

    def input_controller
      if !@input_controller
        @input_controller = WcREPL::InputController.new(window_manager)
      end
      return @input_controller
    end
    
    def output_controller
      if !@output_controller
        @output_controller = WcREPL::OutputController.new(window_manager)
      end
      return @output_controller
    end
    
    def window_manager
      if !@window_manager
        @window_manager = WcREPL::WindowManager.new
      end
      return @window_manager
    end

  end
end