defmodule AdventOfCode.Day5 do
  import AdventOfCode.Utils

  def sum_of_correct_middle_pages(input) do
    input
    |> break_into_rows(true)
    |> parse_rules_and_updates()
    |> select_correct_updates()
    |> extract_updates()
    |> find_middle_pages()
    |> sum()
  end

  def sum_of_corrected_middle_pages(input) do
    input
    |> break_into_rows(true)
    |> parse_rules_and_updates()
    |> select_incorrect_updates()
    |> correct_updates()
    |> extract_updates()
    |> find_middle_pages()
    |> sum()
  end

  defp correct_updates({rules, updates}) do
    updates =
      updates
      |> Enum.map(fn update ->
        correct(update, rules)
      end)

    {rules, updates}
  end

  defp correct(update, rules) do
    swaps =
      Enum.flat_map(rules, fn {left, right} ->
        left_indices = find_indecies_of(update, left)
        right_indices = find_indecies_of(update, right)

        Enum.zip(left_indices, right_indices)
        |> Enum.filter(fn {l, r} -> l > r end)
      end)

    corrected_update =
      if length(swaps) == 0 do
        update
      else
        {l, r} = Enum.at(swaps, 0)
        lv = Enum.at(update, l)
        rv = Enum.at(update, r)

        update
        |> replace_at(l, rv)
        |> replace_at(r, lv)
      end

    if valid_update?(corrected_update, rules) do
      corrected_update
    else
      correct(corrected_update, rules)
    end
  end

  defp replace_at(list, index, value) do
    Enum.with_index(list)
    |> Enum.map(fn
      {_, ^index} -> value
      {element, _} -> element
    end)
  end

  defp extract_updates({_rules, updates}), do: updates

  defp select_incorrect_updates({rules, updates}) do
    updates =
      updates
      |> Enum.filter(fn update ->
        !valid_update?(update, rules)
      end)

    {rules, updates}
  end

  defp select_correct_updates({rules, updates}) do
    updates =
      updates
      |> Enum.filter(fn update ->
        valid_update?(update, rules)
      end)

    {rules, updates}
  end

  defp valid_update?(update, rules) do
    rules
    |> Enum.all?(fn {left, right} ->
      left_indices = find_indecies_of(update, left)
      right_indices = find_indecies_of(update, right)

      Enum.zip(left_indices, right_indices)
      |> Enum.all?(fn {l, r} -> l < r end)
    end)
  end

  defp find_indecies_of(list, matcher) when is_function(matcher) do
    list
    |> Enum.with_index()
    |> Enum.map(fn {element, index} ->
      if matcher.(element), do: index, else: nil
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp find_indecies_of(list, match) do
    find_indecies_of(list, fn element -> element == match end)
  end

  defp find_middle_pages(updates) do
    updates
    |> Enum.map(fn update ->
      middle = floor(length(update) / 2)
      Enum.at(update, middle)
    end)
  end

  defp parse_rules_and_updates(input) when is_list(input) do
    input
    |> init_parser()
    |> parse_rules_and_updates()
    |> format_parser_result()
  end

  defp parse_rules_and_updates({%{section: :rules} = state, ["" | rest]}) do
    parse_rules_and_updates({Map.put(state, :section, :updates), rest})
  end

  defp parse_rules_and_updates({%{section: :rules} = state, [input | rest]}) do
    rule =
      input
      |> String.split("|", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()

    rules = [rule | state.rules]

    parse_rules_and_updates({Map.put(state, :rules, rules), rest})
  end

  defp parse_rules_and_updates({%{section: :updates} = state, ["" | rest]}) do
    {state, rest}
  end

  defp parse_rules_and_updates({%{section: :updates} = state, [input | rest]}) do
    update =
      input
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)

    updates = [update | state.updates]

    parse_rules_and_updates({Map.put(state, :updates, updates), rest})
  end

  defp parse_rules_and_updates({state, input}) do
    state =
      state
      |> Map.update(:rules, [], &Enum.reverse/1)
      |> Map.update(:updates, [], &Enum.reverse/1)

    {state, input}
  end

  defp init_parser(input) do
    state = %{
      section: :rules,
      rules: [],
      updates: []
    }

    {state, input}
  end

  defp format_parser_result({state, _}) do
    {state.rules, state.updates}
  end
end
