require 'json'

TEST_DATA_CONSTANTS_FILE = File.join(File.dirname(__FILE__), 'test_data_constants')
require TEST_DATA_CONSTANTS_FILE

module WcSearch
  module Tests
    module Parser

      def self.parse(json)
        hash = JSON.parse(json)
        get_test_files_hash(hash)
      end

      # Model
      class TestFile
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
        class TestLine
          attr_reader :number, :matches
          def initialize(number)
            @number = number
            @matches = Array.new
          end
          class TestMatch
            attr_reader :text
            def initialize(text)
              @text = text
            end
          end
        end
      end

      private

      def self.get_test_files_hash(hashes)
        test_files_hash = Hash.new
        test_lines_hash = Hash.new

        hashes.each { |hash|
          file_path = hash[FILE_PATH_KEY]
          display_file_path = hash[DISPLAY_FILE_PATH_KEY]
          line_number = hash[LINE_NUMBER_KEY].to_i
          matched_text = hash[MATCHED_TEXT_KEY]

          test_file = test_files_hash[file_path]
          if !test_file
            test_file = TestFile.new(file_path, display_file_path)
            test_files_hash[file_path] = test_file
            # Create a new test_lines_hash, this will break if our test data isn't ordered
            test_lines_hash = Hash.new
          end

          test_line = test_lines_hash[line_number]
          if !test_line
            test_line = TestFile::TestLine.new(line_number)
            test_lines_hash[line_number] = test_line
            test_file.lines.push(test_line)
          end

          match = TestFile::TestLine::TestMatch.new(matched_text)
          test_line.matches.push(match)
        }

        return test_files_hash
      end

    end
  end
end