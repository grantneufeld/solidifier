module Progress

  # A receiver for progress messages that just ignores those messages
  class ProgressNull

    def initialize(params={}); end

    def puts(message); end

    def print(message); end

    def nil?
      true
    end

  end

end
