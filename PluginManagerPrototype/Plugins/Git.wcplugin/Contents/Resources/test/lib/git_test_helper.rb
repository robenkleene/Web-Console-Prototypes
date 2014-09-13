module WcGit
  module Tests

    require 'fileutils'
    require 'rugged'


    class GitHelper
      attr_reader :path
      def initialize
        path = `mktemp -d /tmp/git_test_helper-XXXXXX`
        @path = path.chomp 
      end

      def add_file(filename, content = nil)
        file = File.join(@path, filename)
        file_path = File.expand_path(file)

        # Create missing directories
        directory_path = File.dirname(file_path)
        unless File.directory?(directory_path)
          FileUtils.mkdir_p(directory_path)
        end

        # Write file
        File.open(file_path, 'w') { |f| 
          content = content || ""
          f.write(content) 
        }
      end

      def git_init
        Rugged::Repository.init_at(@path)
      end

      def clean_up
        FileUtils.rm_rf(@path)
      end
    end
  end
end