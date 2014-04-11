require WebConsole::shared_resource("ruby/wcrepl/wcrepl")

module WcNode
  class OutputController < WcREPL::OutputController
    def parse_output(output)

      if output =~ /\x1b[^G]*G\x1b[^J]*J\>\s\x1b[^G]*G/
        # Don't add echo of input
        return
      end
      super(output)
    end
  end
  
end