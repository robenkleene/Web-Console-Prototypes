SEARCH_COMMAND = "ack --color --nogroup"

module WcSearch
  class Parser
    ANSI_ESCAPE = '\x1b[^m]*m'
    MATCH_REGEXP = Regexp.new("#{ANSI_ESCAPE}(.+?)#{ANSI_ESCAPE}")
    METADATA_REGEXP = Regexp.new((MATCH_REGEXP.source) + ":#{ANSI_ESCAPE}([0-9]+)#{ANSI_ESCAPE}:")
    LINE_ENDING = "#{ANSI_ESCAPE}" + '\x1b\[K'
    TEXT_REGEXP = Regexp.new("#{ANSI_ESCAPE}.+?#{ANSI_ESCAPE}:#{ANSI_ESCAPE}[0-9]+#{ANSI_ESCAPE}:(.*?)#{LINE_ENDING}")
  end
end