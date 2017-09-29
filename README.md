# stoertebeker

Headless (pun about [Störtebeker](https://en.wikipedia.org/wiki/Klaus_St%C3%B6rtebeker)) integration testing of crystal web-applications.

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

```crystal
# create the context
context = Stoertebeker::Context.new
```

```crystal
# run starts the electron-server, and the crystal client for electron
Stoertebeker.run(context) do
  context.run do |c|
    c.request("localhost:3001/example.html")
    c.wait_for("h1")
    # c.screenshot("./test.png")
  end
end

```


## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/[your-github-name]/stoertebeker/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [Ragmaanir](https://github.com/ragmaanir) - creator, maintainer
