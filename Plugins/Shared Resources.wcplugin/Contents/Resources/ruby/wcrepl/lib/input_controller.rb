require 'webconsole'

module WcREPL
  class InputController < WebConsole::Controller
    BASE_DIRECTORY = File.join(File.dirname(__FILE__), "..")
    VIEWS_DIRECTORY = File.join(BASE_DIRECTORY, "view")
    VIEW_TEMPLATE = File.join(VIEWS_DIRECTORY, 'view.html.erb')

    def initialize(delegate = nil, view_template = nil)
      if !view_template
        view_template = VIEW_TEMPLATE
      end
      super(delegate, view_template)
    end

    def parse_input(input)
      input = input.dup
      input.chomp!
      input.javascript_escape!
      if !input.strip.empty? # Ignore empty lines
        javascript = %Q[WcREPL.addInput('#{input}');]
        if @delegate
          @delegate.do_javascript(javascript)
        end
      end

    end

    def wcrepl_header_tags
      return %Q[
    #{wcrepl_stylesheet_link_tag}
    #{wcrepl_handlebars_template_tags}
    #{shared_javascript_include_tag("handlebars")}
  	#{shared_javascript_include_tag("zepto")}
    #{wcrepl_javascript_include_tag}
      ]
    end

    def wcrepl_handlebars_template_tags
      return %Q[
    <script id="output-template" type="text/x-handlebars-template">
  		<pre class="output"><code>{{code}}</code></pre>
  	</script>
  	<script id="input-template" type="text/x-handlebars-template">
  		<pre><code>{{code}}</code></pre>
  	</script>]
    end

    def wcrepl_stylesheet_link_tag
      return shared_stylesheet_link_tag("../ruby/wcrepl/css/style")
    end

    def wcrepl_javascript_include_tag
      return shared_javascript_include_tag("../ruby/wcrepl/js/wcrepl")
    end
  end
end