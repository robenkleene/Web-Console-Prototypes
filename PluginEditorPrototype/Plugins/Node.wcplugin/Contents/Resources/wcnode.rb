#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), "lib", "wrapper")

ENV['NODE_PATH'] = "/usr/local/share/npm/lib/node_modules:/usr/local/lib/node_modules"
wrapper = WcNode::Wrapper.new

ARGF.each do |line|
  wrapper.parse_input(line)
end