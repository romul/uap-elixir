defmodule UserAgentParser do
  use Application

  def start(_type, _args) do
    UA.Parser.start_link()
  end

  @doc """
  Parses a user agent.
  """
  @spec parse(String.t) :: {UA.Browser.t, UA.OS.t, UA.Device.t}
  defdelegate parse(ua), to: UA.Parser

  @doc """
  Detects a browser by a user agent.
  """
  @spec detect_browser(String.t) :: UA.Browser.t
  defdelegate detect_browser(ua), to: UA.Parser

  @doc """
  Detects an OS by a user agent.
  """
  @spec detect_os(String.t) :: UA.OS.t
  defdelegate detect_os(ua), to: UA.Parser

  @doc """
  Detects a device by a user agent.
  """
  @spec detect_device(String.t) :: UA.Device.t
  defdelegate detect_device(ua), to: UA.Parser
end
