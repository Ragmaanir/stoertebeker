# stoertebeker [![Build Status](https://travis-ci.org/Ragmaanir/stoertebeker.svg?branch=master)](https://travis-ci.org/Ragmaanir/stoertebeker)[![Dependency Status](https://shards.rocks/badge/github/ragmaanir/stoertebeker/status.svg)](https://shards.rocks/github/ragmaanir/stoertebeker)

Headless (pun about [Störtebeker](https://en.wikipedia.org/wiki/Klaus_St%C3%B6rtebeker)) integration testing of crystal web-applications.

### Version 0.2.0
This very alpha. PRs and help welcome!

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  stoertebeker:
    github: ragmaanir/stoertebeker
```

## Usage

```crystal
require "stoertebeker"
```

### Example
Currently you need to instantiate a context (might change soon, was experimenting a bit). The context creates the electron server (headless browser based on electron, server written in typescript) and the crystal client which communicate via IPC. The server accepts a series of commands which are sent by the client (like request-a-url or take-a-screenshot).

```crystal
# create the context
context = Stoertebeker::Context.new

# run starts the electron-server, and the crystal client for electron
Stoertebeker.run(context) do
  context.run do |c|
    c.request("localhost:3001/example.html")
    c.wait_for("h1")
    # c.screenshot("./test.png")
  end
end
```

I recommend a separate test setup for integration tests (so it is easy to do different setups for these kind of specs, like resetting the DB, clearing caches etc).


#### Using Microtest

```crystal
# spec_helper.cr
require "microtest"
require "http/server"

require "stoertebeker"

include Microtest::DSL

LOGGER = Logger.new(STDOUT)

CTX = Stoertebeker::Context.new(LOGGER)

success = false

Stoertebeker.run(CTX) do |ctx|
  begin
    # start your http server here
    ctx.logger.debug("Starting http server")
    server_process = Process.fork do
      HTTP::Server.new("localhost", 3001, [
        HTTP::ErrorHandler.new,
        HTTP::StaticFileHandler.new("./spec/public", directory_listing: false),
      ]).listen
    end
    ctx.logger.debug("Started http server")

    success = Microtest.run
  ensure
    # make sure the http server is terminated. The electron server and crystal client should be terminated automatically (hopefully, multiple processes are a bitch).
    ctx.logger.debug("Stopping http server")
    server_process.try(&.kill) rescue nil
    ctx.logger.debug("Stopped http server")
  end
end

exit success ? 0 : -1

# xyz_spec.cr
require "./spec_helper"

describe Stoertebeker do
  test "static html example" do
    CTX.run do |c|
      c.request("localhost:3001/example.html")
      c.wait_for("h1")
      # c.screenshot("./test.png")
    end
  end

  test "another static html example" do
    CTX.run do |c|
      c.request("localhost:3001/example.html")
      c.wait_for("h1")
      # c.screenshot("./another_test.png")
    end
  end
end

```

Minitest and the regular crystal spec setup should be similar.

## TODO

- [ ] Multiple windows and parallel testing
- [ ] Better specs

## Development

Some internals:

- The electron server is in `/browser` and uses IPC to accept a few commands
- The crystal client provides methods to send these commands an wait for the response (synchronous)
- Starting and stopping server and client is annoying and not exactly deterministic. I am no expert in that. But so far it works.
- Only one window is used currently and the electron instance can only deal with one test at a time. But ideally it should probably be able to run several tests in parallel. Maybe this could be done with multiple electron server instances instead of complicating the test setup.
- The `README.md` is generated from `README.md.template` by running `./build`. There is a pre-commit hook `hooks/pre-commit` that you can set up by symlinking it to `.git/hooks/pre-commit`.

## Contributing

1. Fork it ( https://github.com/[your-github-name]/stoertebeker/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [Ragmaanir](https://github.com/ragmaanir) - creator, maintainer
