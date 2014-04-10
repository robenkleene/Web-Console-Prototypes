#!/usr/bin/env ruby

require 'webconsole'

LIB_DIRECTORY = File.join(File.dirname(__FILE__), "lib")
CONTROLLER_FILE = File.join(LIB_DIRECTORY, "controller")
require CONTROLLER_FILE

# Window Manager
window_manager = WebConsole::WindowManager.new
BASE_PATH = File.expand_path(File.dirname(__FILE__))
window_manager.base_url_path = BASE_PATH

# Controller
controller = WcPrint::Controller.new(window_manager)

ARGF.each do |line|
  controller.parse_line(line)
end