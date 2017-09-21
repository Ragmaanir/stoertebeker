require "./spec_helper"

describe Stoertebeker::CommandChainBuilder do
  include Stoertebeker

  test "" do
    client = RemoteClient.new

    builder = CommandChainBuilder.new(client)

    chain = builder
      .goto("https://duckduckgo.com")
      .fill("#search_form_input_homepage", "github nightmare")
      .click("#search_button_homepage")
      .wait("#r1-0 a.result__a")
      .result

    expected_chain = CommandChain.new(client, [
      GotoCommand.new(client, "https://duckduckgo.com"),
      FillCommand.new(client, "#search_form_input_homepage", "github nightmare"),
      ClickCommand.new(client, "#search_button_homepage"),
      WaitCommand.new(client, "#r1-0 a.result__a"),
    ] of Command)

    assert(chain == expected_chain)
  end
end
