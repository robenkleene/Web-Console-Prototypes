require WebConsole::shared_resource("ruby/wcrepl/wcrepl")

module WcCoffee
  class InputController < WcREPL::InputController
    BASE_DIRECTORY = File.join(File.dirname(__FILE__), "..")
    VIEWS_DIRECTORY = File.join(BASE_DIRECTORY, "view")
    VIEW_TEMPLATE = File.join(VIEWS_DIRECTORY, 'view.html.erb')

    def initialize(delegate = nil)      
      super(delegate, VIEW_TEMPLATE)
    end
    
    def parse_input(input)
      input = input.dup
      input.gsub!("\uFF00", "\n")
      super(input)
    end

  end
end