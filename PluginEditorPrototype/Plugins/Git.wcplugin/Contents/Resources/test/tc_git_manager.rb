#!/usr/bin/env ruby

require "test/unit"

TEST_CONSTANTS_FILE = File.join(File.dirname(__FILE__), "lib", "test_constants")
require TEST_CONSTANTS_FILE

require TEST_GIT_HELPER_FILE
require TEST_DATA_FILE

require GIT_MANAGER_FILE

class TestGitManager < Test::Unit::TestCase

  def test_git_manager
    git_helper = WcGit::Tests::GitHelper.new
    git_helper.add_file(TEST_FILE_ONE, TEST_FILE_ONE_CONTENT)
    git_helper.add_file(TEST_FILE_TWO, TEST_FILE_TWO_CONTENT)
    git_helper.git_init

    git_manager = WcGit::GitManager.new(git_helper.path.to_s)

    git_manager.git_status
    
  
    git_helper.clean_up
  end

  # def test_git_manager2
  #   git_manager = WcGit::GitManager.new("/tmp/git_test_helper-uU4Ish")
  # 
  #   git_manager.git_status
  # end

end