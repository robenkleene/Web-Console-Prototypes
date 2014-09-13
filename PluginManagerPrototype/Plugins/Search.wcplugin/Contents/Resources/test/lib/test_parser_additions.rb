require File.join(File.dirname(__FILE__), 'test_constants')
require PARSER_FILE

module WcSearch
  class Parser
    attr_reader :files_hash
    def parse(data)
      data.each_line { |line|
          parse_line(line)
      }
    end
  end
end