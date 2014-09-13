require WebConsole::shared_resource("ruby/wcrepl/wcrepl")

module WcIRB
  class OutputController < WcREPL::OutputController
    def parse_output(output)
      if output =~ /^irb\([^)]*\):[^:]*:[^>]*>/
        # Don't add echo of input
        return
      end

      output = output.dup
      output.sub!(/^=>\s/, "") # Remove output prompt
      super(output)
    end
  end
  
end