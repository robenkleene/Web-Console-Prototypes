require 'Shellwords'

TEST_SCRIPT_CONSTANTS_FILE = File.join(File.dirname(__FILE__), 'test_script_constants')
require TEST_SCRIPT_CONSTANTS_FILE # Get the TEST_DATA_DIRECTORY

module WcSearch
  module Tests
    module TestData
      TEST_SCRIPTS_DIRECTORY = File.join(File.dirname(__FILE__), "..", "scripts")

      def self.test_data_directory
        return TEST_DATA_DIRECTORY
      end

      def self.test_search_term
        return SEARCH_TERM
      end

      TEST_SEARCH_OUTPUT_FILE = File.join(TEST_SCRIPTS_DIRECTORY, "test_search_output.rb")    
      def self.test_search_output
        command = Shellwords.escape(TEST_SEARCH_OUTPUT_FILE)
        result = `#{command}`
        return result
      end
      TEST_DATA_JSON_FILE = File.join(TEST_SCRIPTS_DIRECTORY, "test_data_json.rb")
      def self.test_data_json
        command = Shellwords.escape(TEST_DATA_JSON_FILE)
        result = `#{command}`
        return result
      end
    end
  end
end