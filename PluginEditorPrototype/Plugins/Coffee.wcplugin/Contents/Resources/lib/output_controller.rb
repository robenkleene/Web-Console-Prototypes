require WebConsole::shared_resource("ruby/wcrepl/wcrepl")

module WcCoffee
  class OutputController < WcREPL::OutputController
    def parse_output(output)
      if output =~ /^\x1b[^coffee>]*coffee>/
        # Don't add echo of input
        return
      end
      super(output)
    end
  end
  
end