require "./commands"

module Stoertebeker
  module DSL
    include Commands

    def ping
      PingCommand.new(client).call
    end

    def window(**args)
      WindowCommand.new(client, **args).call
    end

    def request(*args)
      GotoCommand.new(client, *args).call
    end

    def wait_for(*args)
      WaitCommand.new(client, *args).call
    end

    def execute(*args)
      EvaluateCommand.new(client, *args).call
    end

    def execute(*args, &block : (JSON::Any ->))
      EvaluateCommand.new(client, *args, block).call
    end

    def evaluate(script)
      value = JSON::Any.new(nil)

      execute(script) do |res|
        value = res
      end

      value
    end

    def current_url
      evaluate("document.location.href").as_s
    end

    def current_path
      evaluate("document.location.pathname").as_s
    end

    def page_title
      evaluate("document.title").as_s
    end

    def exists?(selector)
      evaluate("document.querySelector('#{selector}') != null").as_b
    end

    def screenshot(*args)
      ScreenshotCommand.new(client, *args).call
    end

    def quit(*args)
      QuitCommand.new(client, *args).call
    end
  end
end
