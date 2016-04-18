# UserAgentParser

UserAgentParser is a simple Elixir package for parsing user agent strings. It uses [BrowserScope](http://www.browserscope.org/)'s [parsing patterns](https://github.com/ua-parser/uap-core).

## Installation

  1. Add user_agent_parser to your list of dependencies in `mix.exs`:

        def deps do
          [{:user_agent_parser, "~> 1.0"}]
        end

  2. Ensure user_agent_parser is started before your application:

        def application do
          [applications: [:user_agent_parser]]
        end

  3. Add `worker(UA.Parser, []),` to your supervisor tree

## Usage example

```elixir
iex(1)> user_agent = "Mozilla/5.0 (compatible; MSIE 10.0; Windows Phone 8.0; Trident/6.0; IEMobile/10.0; ARM; Touch; Microsoft; Lumia 640 XL)"
iex(2)> UserAgentParser.detect_browser(user_agent)
%UA.Browser{family: "IE Mobile", version: "10.0"}
iex(2)> UserAgentParser.detect_os(user_agent)
%UA.OS{family: "Windows Phone", version: "8.0"}
iex(3)> UserAgentParser.detect_device(user_agent)
%UA.Device{brand: "Microsoft", model: "Lumia 640 XL", name: "Microsoft Lumia 640 XL"}
iex(4)> UserAgentParser.parse(user_agent)
{%UA.Browser{family: "IE Mobile", version: "10.0"},
 %UA.OS{family: "Windows Phone", version: "8.0"},
 %UA.Device{brand: "Microsoft", model: "Lumia 640 XL",
  name: "Microsoft Lumia 640 XL"}}
```
