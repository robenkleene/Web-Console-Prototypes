require 'webconsole'

module WcREPL
  class OutputController < WebConsole::Controller
    def initialize(delegate = nil)
      @delegate = delegate
    end

    def parse_output(output)
      output = output.dup
      output.gsub!(/\x1b[^m]*m/, "") # Remove escape sequences
      output.chomp!
      output.javascript_escape!
      if !output.strip.empty? # Ignore empty lines
        javascript = %Q[WcREPL.addOutput('#{output}');]
        if @delegate
          @delegate.do_javascript(javascript)
        end
      end
    end
  end
end