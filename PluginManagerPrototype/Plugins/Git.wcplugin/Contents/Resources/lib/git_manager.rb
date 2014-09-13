

module WcGit

  require 'rugged'
  class GitManager
    def initialize(path)
      @path = path


      @repo = Rugged::Repository.new(@path)
      @index = @repo.index


      puts @index.inspect
      # @index = Rugged::Index.new(path)
    end        

    def git_status
      puts "got here"
      puts @repo.inspect
      puts @repo.status {|path, status_data| 
        puts "path = #{path}, status_data = #{status_data}"
        # puts "status_data = #{status_data} status_data.inspect = #{status_data.inspect}"
      }

      @index.each { |i| 
        puts i.inspect
      }
    end

  end

end