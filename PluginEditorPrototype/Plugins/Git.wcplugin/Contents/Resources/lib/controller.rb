require 'webconsole'
require 'slim'

module WcGit


  class Controller < WebConsole::Controller

    attr_accessor :branch

    BASE_DIRECTORY = File.join(File.dirname(__FILE__), "..")
    VIEWS_DIRECTORY = File.join(BASE_DIRECTORY, "views")
    VIEW_TEMPLATE = File.join(VIEWS_DIRECTORY, 'view.slim')
    def initialize(delegate = nil)
      @delegate = delegate

      Slim::Engine.set_default_options :attr_delims => {'(' => ')', '[' => ']'} # Allow Handlebars syntax
      template_slim = Slim::Template.new(VIEW_TEMPLATE, :pretty => true)
      html = template_slim.render(self)

      if @delegate
        @delegate.load_html(html)
      end
    end

    def branch_name
      branch_name = nil
      if @delegate
        coffeescript = "return wcGit.branchName"
        branch_name = @delegate.do_coffeescript(coffeescript)
        branch_name.chomp!
        if branch_name.empty?
          branch_name = nil
        end
      end
      return branch_name
    end

    def branch_name=(value)
      if @delegate
        value ||= ""
        coffeescript = "wcGit.branchName = '#{value.javascript_escape}'"
        @delegate.do_coffeescript(coffeescript)
      end
    end
  end
end