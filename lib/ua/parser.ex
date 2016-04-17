defmodule UA.Parser do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def parse(user_agent) do
    GenServer.call(__MODULE__, {:parse, user_agent})
  end

  def detect_browser(user_agent) do
    GenServer.call(__MODULE__, {:detect_browser, user_agent})
  end

  def detect_os(user_agent) do
    GenServer.call(__MODULE__, {:detect_os, user_agent})
  end

  def detect_device(user_agent) do
    GenServer.call(__MODULE__, {:detect_device, user_agent})
  end

  @data UA.Data.preload
  defp data do
    @data
  end

  def handle_call({:parse, ua}, _from, state) do
    browser = do_detect_browser(ua)
    os = do_detect_os(ua)
    device = do_detect_device(ua)
    {:reply, {browser, os, device}, state}
  end

  def handle_call({:detect_browser, ua}, _from, state) do
    {:reply, do_detect_browser(ua), state}
  end

  def handle_call({:detect_os, ua}, _from, state) do
    {:reply, do_detect_os(ua), state}
  end

  def handle_call({:detect_device, ua}, _from, state) do
    {:reply, do_detect_device(ua), state}
  end


  defp do_detect_browser(ua) do
    data[:user_agent_parsers]
    |> Enum.find(fn(%{regex: regex}) -> Regex.run(regex, ua) end)
    |> parse_browser(ua)
  end

  defp parse_browser(nil, _), do: :unknown
  defp parse_browser(parser, ua) do
    family_repl = parser[:family_replacement]
    v1_repl = parser[:v1_replacement]
    v2_repl = parser[:v2_replacement]
    version = [v1_repl, v2_repl] |> Enum.filter(&(&1 != nil)) |> version_from_parts

    case Regex.run(parser[:regex], ua) do
      [_, family | ver_parts] ->
        %UA.Browser{
          family: family_repl || family,
          version: version || version_from_parts(ver_parts)
        }
      [_] ->
        %UA.Browser{
          family: family_repl,
          version: version || :unknown
        }
    end
  end

  def do_detect_os(ua) do
    data[:os_parsers]
    |> Enum.find(fn(%{regex: regex}) -> Regex.run(regex, ua) end)
    |> parse_os(ua)
  end

  defp parse_os(nil, _), do: :unknown
  defp parse_os(parser, ua) do
    os_repl = parser[:os_replacement]
    v1_repl = parser[:os_v1_replacement]
    v2_repl = parser[:os_v2_replacement]
    v3_repl = parser[:os_v3_replacement]
    version = [v1_repl, v2_repl, v3_repl] |> Enum.filter(&(&1 != nil)) |> version_from_parts

    case Regex.run(parser[:regex], ua) do
      [_, os | ver_parts] ->
        %UA.OS{
          family: os_repl || os,
          version: version || version_from_parts(ver_parts)
        }
      [_] ->
        %UA.OS{ family: os_repl, version: version || :unknown }
    end
  end

  def do_detect_device(ua) do
    data[:device_parsers]
    |> Enum.find(fn(%{regex: regex}) -> Regex.run(regex, ua) end)
    |> parse_device(ua)
  end

  defp parse_device(nil, _), do: :unknown
  defp parse_device(parser, ua) do
    substitutions = case Regex.run(parser[:regex], ua) do
      [_, device, brand, model] -> [{"$1", device}, {"$2", brand}, {"$3", model}]
      [_, device, brand] -> [{"$1", device}, {"$2", brand}]
      [_, device] -> [{"$1", device}]
      [_] -> []
    end
    %UA.Device{
      name: make_substitutions(parser[:device_replacement], substitutions),
      brand: make_substitutions(parser[:brand_replacement], substitutions),
      model: make_substitutions(parser[:model_replacement], substitutions)
    }
  end

  defp version_from_parts([]), do: nil
  defp version_from_parts(parts), do: Enum.join(parts, ".")

  defp make_substitutions(:unknown, _), do: :unknown
  defp make_substitutions(string, substitutions) do
    substitutions |> Enum.reduce(string, fn({k, v}, string) ->
      String.replace(string, k, v)
    end)
  end
end
