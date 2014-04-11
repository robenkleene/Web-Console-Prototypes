require 'webconsole'
require 'redcarpet'

module WcMarkdown
  class Controller < WebConsole::Controller
    BASE_DIRECTORY = File.join(File.dirname(__FILE__), "..")
    VIEWS_DIRECTORY = File.join(BASE_DIRECTORY, "views")
    VIEW_TEMPLATE = File.join(VIEWS_DIRECTORY, 'view.html.erb')

    def initialize(delegate = nil, markdown = nil, filename = nil)
      @renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)
      @html = @renderer.render(markdown)
      @filename = filename

      super(delegate, VIEW_TEMPLATE)
    end

    def body_content
      return @html
    end    

    def title_content
      if !@filename
        return "Markdown Preview"
      end
      return @filename
    end

    def markdown=(markdown)
      @html = @renderer.render(markdown)

      javascript = "replaceContent('#{@html.javascript_escape}');"

      if @delegate
        @delegate.do_javascript(javascript)
      end
    end

  end
end