require 'webconsole'

module WcMarkdown
  class WindowManager < WebConsole::WindowManager
    BASE_DIRECTORY = File.join(File.dirname(__FILE__), '..')

    def initialize(window_id = nil)
      super(window_id)
      self.base_url_path = File.expand_path(BASE_DIRECTORY)
    end
  end
end