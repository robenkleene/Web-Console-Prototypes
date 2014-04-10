#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), "lib", "wrapper")

wrapper = WcCoffee::Wrapper.new

ARGF.each do |line|  
  wrapper.parse_input(line)
end