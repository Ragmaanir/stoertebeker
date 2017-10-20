require "./commands"

module Stoertebeker
  module DSL
    include Commands

    # Used to check whether the server responds
    def ping
      PingCommand.new(client).call
    end

    # Sets the window width and height
    #
    # ```
    # window(width: 1024, height: 768)
    # ```
    #
    def window(**args)
      WindowCommand.new(client, **args).call
    end

    # Instructs electron to load a website:
    #
    # ```
    # request("http://localhost:3001/example.html")
    # ```
    def request(*args)
      GotoCommand.new(client, *args).call
    end

    # Waits for an element to be present.#
    #
    # *tries*: the number of times the selector will be queried for (default 10)
    # *delay*: the delay between each try in ms (default 20)
    #
    # ```
    # wait_for("h1#example1", tries: 5, delay: 20)
    # ```
    def wait_for(*args, **kwargs)
      WaitCommand.new(client, *args, **kwargs).call
    end

    # Simulates a click on an element identified by the passed selector.
    # If the selector matches multiple elements, an error is raised.
    def click(selector)
      result = evaluate <<-JAVASCRIPT
        var elements = document.querySelectorAll("#{selector}");
        var res = "";

        if(elements.length == 1) {
          elements[0].click();
          res = "ok";
        } else {
          res = "Expected one element but got: " + elements.length;
        }

        res;
      JAVASCRIPT

      raise("Error: #{result}") if result != "ok"
    end

    # Sets the value of an input element, e.g. a text field.
    #
    # ```
    # set_value(".textfield", "somevalue")
    # ```
    def set_value(selector, value)
      value = case value
              when nil    then "null"
              when String then value.inspect
              else             value.to_s
              end

      result = evaluate <<-JAVASCRIPT
        var elements = document.querySelectorAll("#{selector}");
        var res = "";

        if(elements.length == 1) {
          elements[0].value = #{value};
          res = "ok";
        } else {
          res = "Expected one element but got: " + elements.length;
        }

        res;
      JAVASCRIPT

      raise("Error: #{result}") if result != "ok"
    end

    # Returns the innerHTML of an element matched by the selector.
    def inner_html(selector)
      evaluate("document.querySelector('#{selector}').innerHTML")
    end

    # Runs javascript without returning a value.
    def execute(*args)
      EvaluateCommand.new(client, *args).call
    end

    # Runs the passed javascript and invokes the block with the output of the javascript (JSON).
    def execute(*args, &block : (JSON::Any ->))
      EvaluateCommand.new(client, *args, block).call
    end

    # Executes javascript and returns the resulting value (JSON).
    def evaluate(script)
      value = JSON::Any.new(nil)

      execute(script) do |res|
        value = res
      end

      value
    end

    # Returns the url of the currently displayed website.
    def current_url
      evaluate("document.location.href").as_s
    end

    # Returns the path of the currently displayed website.
    def current_path
      evaluate("document.location.pathname").as_s
    end

    # Returns the title of the DOM of the currently displayed website.
    def page_title
      evaluate("document.title").as_s
    end

    # Returns true if the selector matches anything on the currently displayed website.
    # The call does not wait for the element to show up, it checks the DOM immediately.
    def exists?(selector)
      evaluate("document.querySelector('#{selector}') != null").as_b
    end

    # Saves a screenshot of the currently displayed website.
    #
    # ```
    # screenshot("./temp/example2.png")
    # ```
    def screenshot(*args)
      ScreenshotCommand.new(client, *args).call
    end

    # Terminates the electron server.
    def quit(*args)
      QuitCommand.new(client, *args).call
    end
  end
end
