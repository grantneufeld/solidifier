module Progress

  # A receiver for progress messages that ignores minor messages
  class ProgressMinimal

    def initialize(params={})
      @out = params[:out] || $stdout
    end

    # print the message as a line
    def puts(message)
      @out.puts message
    end

    # ignore minor progress messages
    def print(message); end

  end

end
