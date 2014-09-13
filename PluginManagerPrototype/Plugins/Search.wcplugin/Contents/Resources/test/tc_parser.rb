#!/usr/bin/env ruby

require "test/unit"

TEST_CONSTANTS_FILE = File.join(File.dirname(__FILE__), 'lib', 'test_constants')
require TEST_CONSTANTS_FILE

require TEST_DATA_HELPER_FILE
require TEST_DATA_PARSER_FILE
require TEST_PARSER_ADDITIONS_FILE
require TEST_DATA_TESTER_FILE
require PARSER_FILE

class TestParser < Test::Unit::TestCase

  def test_parser
    test_search_output = WcSearch::Tests::TestData::test_search_output
    test_data_directory = WcSearch::Tests::TestData::test_data_directory
    
    parser = WcSearch::Parser.new(nil, test_data_directory)
    parser.parse(test_search_output)
    files_hash = parser.files_hash

    test_data_json = WcSearch::Tests::TestData::test_data_json
    test_files_hash = WcSearch::Tests::Parser::parse(test_data_json)

    file_hashes_match = WcSearch::Tests::TestDataTester::test_file_hashes(files_hash, test_files_hash)
    assert(file_hashes_match, "The file hashes should match.")
  end
end