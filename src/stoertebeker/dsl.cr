require "./commands"

module Stoertebeker
  module DSL
    include Commands

    def window(**args)
      WindowCommand.new(client, **args).call
    end

    def request(*args)
      GotoCommand.new(client, *args).call
    end

    def wait_for(*args)
      WaitCommand.new(client, *args).call
    end

    def evaluate(*args)
      EvaluateCommand.new(client, *args).call
    end

    def evaluate(*args, &block : (JSON::Any ->))
      EvaluateCommand.new(client, *args, block).call
    end

    def screenshot(*args)
      ScreenshotCommand.new(client, *args).call
    end

    def quit(*args)
      QuitCommand.new(client, *args).call
    end
  end
end
