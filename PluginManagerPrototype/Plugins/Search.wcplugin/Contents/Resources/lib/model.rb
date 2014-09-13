module WcSearch
  module Match
    class File
      attr_reader :file_path, :display_file_path, :lines
      def initialize(file_path, display_file_path = nil)
        @file_path = file_path
        if display_file_path
          @display_file_path = display_file_path
        else
          @display_file_path = file_path
        end
        @lines = Array.new
      end

      class Line
        attr_reader :number, :matches
        attr_accessor :text
        def initialize(number)
          @number = number
          @matches = Array.new
        end

        class Match
          attr_reader :index, :length, :text
          def initialize(index, length, line)
            @index = index
            @length = length
            @line = line
          end

          def text
            @line.text[index..(index + length - 1)]
          end
        end

      end
    end
  end
end
