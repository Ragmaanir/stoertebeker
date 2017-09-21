require "./spec_helper"

describe Stoertebeker::CommandChain do
  include Stoertebeker

  test "" do
    client = RemoteClient.new

    builder = CommandChainBuilder.new(client)

    chain = CommandChain.new(client, [
      GotoCommand.new(client, "https://duckduckgo.com"),
      FillCommand.new(client, "#search_form_input_homepage", "github nightmare"),
      ClickCommand.new(client, "#search_button_homepage"),
      WaitCommand.new(client, "#r1-0 a.result__a"),
    ] of Command)

    skip "need mock server"
    chain.call # (channel)
  end
end
