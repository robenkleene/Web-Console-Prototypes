#!/usr/bin/env ruby

require 'webconsole'
require 'listen'

LIB_DIRECTORY = File.join(File.dirname(__FILE__), "lib")

CONTROLLER_FILE = File.join(LIB_DIRECTORY, "controller")
require CONTROLLER_FILE

WINDOW_MANAGER_FILE = File.join(LIB_DIRECTORY, "window_manager")
require WINDOW_MANAGER_FILE

if !ARGV.empty?
  file = ARGF.file
end
markdown = ARGF.read

window_manager = WcMarkdown::WindowManager.new

if !file
  WcMarkdown::Controller.new(window_manager, markdown)
  exit
end

filename = File.basename(file)
controller = WcMarkdown::Controller.new(window_manager, markdown, filename)

path = File.expand_path(File.dirname(file))

listener = Listen.to(path, only: /^#{Regexp.quote(filename)}$/) { |modified, added, removed| 
  file = File.open(modified[0])
  File.open(file) { |f| 
    controller.markdown = f.read
  }
}

listener.start

trap("SIGINT") {
  exit
}

sleep