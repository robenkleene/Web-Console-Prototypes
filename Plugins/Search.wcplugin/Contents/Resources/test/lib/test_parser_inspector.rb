module WcSearch
  class Tests
    class ParserInspector
      def added_file(file)
        puts "added_file file = " + file.inspect
      end

      def added_line_to_file(line, file)
        puts "added_line_to_file line = " + line.inspect + " file = " + file.inspect
      end
    end
  end
end