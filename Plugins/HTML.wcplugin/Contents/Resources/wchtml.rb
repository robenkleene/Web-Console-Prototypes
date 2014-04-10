#!/usr/bin/env ruby

require 'webconsole'
require 'listen'

LIB_DIRECTORY = File.join(File.dirname(__FILE__), "lib")

CONTROLLER_FILE = File.join(LIB_DIRECTORY, "controller")
require CONTROLLER_FILE

if !ARGV.empty?
  file = ARGF.file
end
html = ARGF.read

if !file
  window_manager = WebConsole::WindowManager.new
  WcMarkdown::Controller.new(window_manager, html)
  exit
end

filename = File.basename(file)
path = File.expand_path(File.dirname(file))

window_manager = WebConsole::WindowManager.new
window_manager.base_url_path = path
controller = WcHTML::Controller.new(window_manager, html)

listener = Listen.to(path, only: /(\.html$)|(\.css$)|(\.js$)/) { |modified, added, removed| 
  File.open(file) { |f| 
    controller.html = f.read
  }
}

listener.start

trap("SIGINT") {
  exit
}

sleep