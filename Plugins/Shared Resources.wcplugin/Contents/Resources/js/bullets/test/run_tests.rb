#!/usr/bin/env ruby

require 'Shellwords'

HTML_FILE = File.join(File.dirname(__FILE__), "lib/index.html")

exec("mocha-phantomjs #{Shellwords.escape(HTML_FILE)}")