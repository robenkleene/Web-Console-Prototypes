#!/usr/bin/env ruby

require "test/unit"

TEST_CONSTANTS_FILE = File.join(File.dirname(__FILE__), "lib", "test_constants")
require TEST_CONSTANTS_FILE

require TEST_WINDOW_MANAGER_HELPER

require CONTROLLER_FILE
require WINDOW_MANAGER_FILE

class TestController < Test::Unit::TestCase

  def test_set_branch
    window_manager = WcGit::WindowManager.new
    controller = WcGit::Controller.new(window_manager)

    assert(controller.branch_name.nil?, "The controller's branch name should be nil before it is set.")

    branch_name = "master"
    controller.branch_name = branch_name
    assert(branch_name == controller.branch_name, "The controller's branch name should equal the branch name.")

    branch_name = "development"
    controller.branch_name = branch_name
    window_manager_test_helper = WcGit::Tests::WindowManagerHelper.new(window_manager)
    branch_element_count = window_manager_test_helper.element_count_for_selector("[id=branch]").to_i # Alternative ID selector syntax will select multiple elements with the same ID.
    assert(branch_element_count == 1, "There should be one branch element.")
    assert(branch_name == controller.branch_name, "The controller's branch name should equal the branch name.")

    controller.branch_name = nil
    assert(controller.branch_name.nil?, "The controller's branch name should be nil after being set to nil.")

    window_manager.close
  end

  def test_staged_files
    # file.status = "modified"
    # file.staged = :staged, :unstaged, :untracked
    # file.path

    # fetchedResultsController pattern:
    # fileDidMoveFromIndexPath to indexPath
  end

end