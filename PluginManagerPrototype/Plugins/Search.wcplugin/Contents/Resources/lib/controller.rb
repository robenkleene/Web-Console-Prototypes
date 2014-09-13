require 'webconsole'

module WcSearch
  class Controller < WebConsole::Controller
    BASE_DIRECTORY = File.join(File.dirname(__FILE__), "..")
    VIEWS_DIRECTORY = File.join(BASE_DIRECTORY, "views")
    VIEW_TEMPLATE = File.join(VIEWS_DIRECTORY, 'view.html.erb')

    def initialize(delegate = nil)      
      super(delegate, VIEW_TEMPLATE)
    end

    def added_file(file)
      file_path = file.file_path
      display_file_path = file.display_file_path
      file_path.javascript_escape!
      display_file_path.javascript_escape!
      javascript = "addFile('#{file_path}', '#{display_file_path}');"
      if @delegate
        @delegate.do_javascript(javascript)
      end
    end

    def added_line_to_file(line, file)
      matches_javascript = ""
      line.matches.each { |match|
        match_javascript = %Q[ 
  {
    index: #{match.index},
    length: #{match.length}
  },]
        matches_javascript << match_javascript
      }
      matches_javascript.chomp!(",");
      text = line.text
      text.javascript_escape!
      javascript = %Q[
var matches = [#{matches_javascript}  
];
addLine(#{line.number}, '#{text}', matches);
]
      if @delegate
        @delegate.do_javascript(javascript)
      end
    end
    
  end
end