module WcHTML
  class Controller

    def initialize(delegate = nil, html)
      @delegate = delegate
      if @delegate
        @delegate.load_html(html)
      end
    end

    def html=(html)
      if @delegate
        @delegate.load_html(html)
      end
    end

  end
end