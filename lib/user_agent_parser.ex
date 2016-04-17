defmodule UserAgentParser do
  @data UA.Data.preload
  defp data do
    @data
  end

  def parse(ua) do
    browser = detect_browser(ua)
    os = detect_os(ua)
    device = detect_device(ua)
    {browser, os, device}
  end

  def detect_browser(ua) do
    parser = data[:user_agent_parsers] |> Enum.find(fn(%{regex: regex} = pattern) -> Regex.run(regex, ua) end)
    parse_browser(ua, parser)
  end

  defp parse_browser(_, nil), do: :unknown
  defp parse_browser(ua, parser) do
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

  defp version_from_parts([]), do: nil
  defp version_from_parts(parts), do: Enum.join(parts, ".")

  def detect_os(ua) do
    parser = data[:os_parsers] |> Enum.find(fn(%{regex: regex} = pattern) -> Regex.run(regex, ua) end)
    parse_os(ua, parser)
  end

  defp parse_os(_, nil), do: :unknown
  defp parse_os(ua, parser) do
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

  def detect_device(ua) do
    parser = data[:device_parsers] |> Enum.find(fn(%{regex: regex} = pattern) -> Regex.run(regex, ua) end)
    parse_device(ua, parser)
  end

  defp parse_device(_, nil), do: :unknown
  defp parse_device(ua, parser) do
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

  defp make_substitutions(:unknown, _), do: :unknown
  defp make_substitutions(string, substitutions) do
    substitutions |> Enum.reduce(string, fn({k, v}, string) ->
      String.replace(string, k, v)
    end)
  end
end
