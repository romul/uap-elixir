defmodule UA.Data do
  @atoms [
    :namespace, :user_agent_parsers,  :os_parsers, :device_parsers,
    :regex, :regex_flag, :family_replacement, :v1_replacement, :v2_replacement,
    :os_replacement, :os_v1_replacement, :os_v2_replacement, :os_v3_replacement,
    :device_replacement, :brand_replacement, :model_replacement
  ]

  def preload do
    data = File.stream!(Path.join([File.cwd!, "vendor", "uap-core", "regexes.yaml"]))
    |> Enum.reduce([], &parse_line/2)
    |> Dict.delete(:namespace)
    |> Enum.map(&compile_regexps/1)
    |> Enum.into(%{})
  end

  defp parse_line(line, acc) do
    line = String.strip(line)
    cond do
      String.starts_with?(line, "#") || line == "" ->
        acc
      String.match?(line, ~r/^\w+:$/) ->
        namespace = String.split(line, ":") |> hd |> String.to_existing_atom
        Dict.put(acc, :namespace, namespace)
      true ->
        namespace = acc[:namespace]
        [key, value] = String.split(line, ": ", parts: 2)
        value = String.strip(value, ?')
        if String.starts_with?(key, "-") do
          parser = %{regex: value}
          Dict.update(acc, namespace, [parser], &([parser|&1]))
        else
          [head|tail] = acc[namespace]
          head = Dict.put(head, String.to_existing_atom(key), value)
          Dict.put(acc, namespace, [head|tail])
        end
    end
  end

  defp compile_regexps({section, parsers}) do
    {
      section,
      parsers
      |> Enum.reverse
      |> Enum.map(fn(parser) ->
          parser
          |> Dict.put(:regex, Regex.compile!(parser[:regex], parser[:regex_flag] || ""))
          |> Dict.delete(:regex_flag)
        end)
    }
  end
end
