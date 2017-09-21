require "./commands"

module Stoertebeker
  include Commands

  class CommandChain
    getter client : Client
    getter commands : Array(Command) = [] of Command

    def initialize(@client, @commands)
    end

    def call
      commands.each do |cmd|
        cmd.call # (channel)
      end
    end

    def_equals_and_hash client, commands
  end

  class CommandChainBuilder
    getter client : Client
    getter commands : Array(Command) = [] of Command

    def initialize(@client)
    end

    def goto(uri : String)
      commands << GotoCommand.new(client, uri)
      self
    end

    def fill(selector : String, value : String)
      commands << FillCommand.new(client, selector, value)
      self
    end

    def click(selector : String)
      commands << ClickCommand.new(client, selector)
      self
    end

    def wait(selector : String)
      commands << WaitCommand.new(client, selector)
      self
    end

    # def evaluate(block)
    #   commands << WaitCommand.new(selector)
    #   self
    # end

    def result
      CommandChain.new(client, commands)
    end
  end
end
