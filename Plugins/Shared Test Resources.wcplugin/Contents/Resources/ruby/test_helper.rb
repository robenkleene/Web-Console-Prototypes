require 'Shellwords'

require File.join(File.dirname(__FILE__), "test_constants")

module WebConsole
  module Tests
    module Helper
      APPLESCRIPT_DIRECTORY = File.join(File.dirname(__FILE__), "..", "applescript")

      def self.run_javascript(javascript)
        return `node -e #{Shellwords.escape(javascript)}`
      end

      CONFIRMDIALOGAPPLESCRIPT_FILE = File.join(APPLESCRIPT_DIRECTORY, "confirm_dialog.applescript")
      def self.confirm_dialog
        self.run_applescript(CONFIRMDIALOGAPPLESCRIPT_FILE)
        sleep TEST_PAUSE_TIME # Give dialog time
      end

      WINDOWIDAPPLESCRIPT_FILE = File.join(APPLESCRIPT_DIRECTORY, "window_id.applescript")
      def self.window_id
        result = self.run_applescript(WINDOWIDAPPLESCRIPT_FILE)
        result.chomp!
        return result      
      end

      CANCELDIALOGAPPLESCRIPT_FILE = File.join(APPLESCRIPT_DIRECTORY, "cancel_dialog.applescript")
      def self.cancel_dialog
        self.run_applescript(CANCELDIALOGAPPLESCRIPT_FILE)
        sleep TEST_PAUSE_TIME # Give dialog time
      end

      QUITAPPLESCRIPT_FILE = File.join(APPLESCRIPT_DIRECTORY, "quit.applescript")
      def self.quit
        self.run_applescript(QUITAPPLESCRIPT_FILE)
      end

      ISRUNNINGAPPLESCRIPT_FILE = File.join(APPLESCRIPT_DIRECTORY, "is_running.applescript")
      def self.is_running
        result = self.run_applescript(ISRUNNINGAPPLESCRIPT_FILE)
        result.chomp!
        if result == "true"
          return true
        else
          return false
        end
      end

      SWITCHWINDOWSAPPLESCRIPT_FILE = File.join(APPLESCRIPT_DIRECTORY, "switch_windows.applescript")
      def self.switch_windows
        self.run_applescript(SWITCHWINDOWSAPPLESCRIPT_FILE)
      end

      WINDOWBOUNDSAPPLESCRIPT_FILE = File.join(APPLESCRIPT_DIRECTORY, "window_bounds.applescript")
      def self.window_bounds(window_id = nil)
        result = self.run_applescript(WINDOWBOUNDSAPPLESCRIPT_FILE, [window_id])
        result.chomp!
        return result
      end

      SETWINDOWBOUNDSAPPLESCRIPT_FILE = File.join(APPLESCRIPT_DIRECTORY, "set_window_bounds.applescript")
      def self.set_window_bounds(bounds, window_id = nil)
        arguments = [bounds]
        if window_id
          arguments = arguments.push(window_id)
        end
        self.run_applescript(SETWINDOWBOUNDSAPPLESCRIPT_FILE, arguments)
      end

      private
  
      def self.run_applescript(script, arguments = nil)
        command = "osascript #{Shellwords.escape(script)}"
        if arguments
          arguments.each { |argument|
            if argument
              argument = argument.to_s
              command = command + " " + Shellwords.escape(argument)
            end
          }
        end
        return `#{command}`
      end

    end
  end
end