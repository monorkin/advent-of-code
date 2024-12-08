defmodule AdventOfCode.Day5 do
  import AdventOfCode.Utils

  # --- Day 5: Print Queue ---
  #
  # Satisfied with their search on Ceres, the squadron of scholars suggests subsequently scanning the stationery stacks of sub-basement 17.
  #
  # The North Pole printing department is busier than ever this close to Christmas, and while The Historians continue their search of this historically significant facility, an Elf operating a very familiar printer beckons you over.
  #
  # The Elf must recognize you, because they waste no time explaining that the new sleigh launch safety manual updates won't print correctly. Failure to update the safety manuals would be dire indeed, so you offer your services.
  #
  # Safety protocols clearly indicate that new pages for the safety manuals must be printed in a very specific order. The notation X|Y means that if both page number X and page number Y are to be produced as part of an update, page number X must be printed at some point before page number Y.
  #
  # The Elf has for you both the page ordering rules and the pages to produce in each update (your puzzle input), but can't figure out whether each update has the pages in the right order.
  #
  # For example:
  #
  # 47|53
  # 97|13
  # 97|61
  # 97|47
  # 75|29
  # 61|13
  # 75|53
  # 29|13
  # 97|29
  # 53|29
  # 61|53
  # 97|53
  # 61|29
  # 47|13
  # 75|47
  # 97|75
  # 47|61
  # 75|61
  # 47|29
  # 75|13
  # 53|13
  #
  # 75,47,61,53,29
  # 97,61,53,29,13
  # 75,29,13
  # 75,97,47,61,53
  # 61,13,29
  # 97,13,75,29,47
  #
  # The first section specifies the page ordering rules, one per line. The first rule, 47|53, means that if an update includes both page number 47 and page number 53, then page number 47 must be printed at some point before page number 53. (47 doesn't necessarily need to be immediately before 53; other pages are allowed to be between them.)
  #
  # The second section specifies the page numbers of each update. Because most safety manuals are different, the pages needed in the updates are different too. The first update, 75,47,61,53,29, means that the update consists of page numbers 75, 47, 61, 53, and 29.
  #
  # To get the printers going as soon as possible, start by identifying which updates are already in the right order.
  #
  # In the above example, the first update (75,47,61,53,29) is in the right order:
  #
  #     75 is correctly first because there are rules that put each other page after it: 75|47, 75|61, 75|53, and 75|29.
  #     47 is correctly second because 75 must be before it (75|47) and every other page must be after it according to 47|61, 47|53, and 47|29.
  #     61 is correctly in the middle because 75 and 47 are before it (75|61 and 47|61) and 53 and 29 are after it (61|53 and 61|29).
  #     53 is correctly fourth because it is before page number 29 (53|29).
  #     29 is the only page left and so is correctly last.
  #
  # Because the first update does not include some page numbers, the ordering rules involving those missing page numbers are ignored.
  #
  # The second and third updates are also in the correct order according to the rules. Like the first update, they also do not include every page number, and so only some of the ordering rules apply - within each update, the ordering rules that involve missing page numbers are not used.
  #
  # The fourth update, 75,97,47,61,53, is not in the correct order: it would print 75 before 97, which violates the rule 97|75.
  #
  # The fifth update, 61,13,29, is also not in the correct order, since it breaks the rule 29|13.
  #
  # The last update, 97,13,75,29,47, is not in the correct order due to breaking several rules.
  #
  # For some reason, the Elves also need to know the middle page number of each update being printed. Because you are currently only printing the correctly-ordered updates, you will need to find the middle page number of each correctly-ordered update. In the above example, the correctly-ordered updates are:
  #
  # 75,47,61,53,29
  # 97,61,53,29,13
  # 75,29,13
  #
  # These have middle page numbers of 61, 53, and 29 respectively. Adding these page numbers together gives 143.
  #
  # Of course, you'll need to be careful: the actual list of page ordering rules is bigger and more complicated than the above example.
  #
  # Determine which updates are already in the correct order. What do you get if you add up the middle page number from those correctly-ordered updates?
  #
  # Your puzzle answer was 3608.

  def sum_of_correct_middle_pages(input) do
    input
    |> break_into_rows(true)
    |> parse_rules_and_updates()
    |> select_correct_updates()
    |> extract_updates()
    |> find_middle_pages()
    |> sum()
  end

  # --- Part Two ---
  #
  # While the Elves get to work printing the correctly-ordered updates, you have a little time to fix the rest of them.
  #
  # For each of the incorrectly-ordered updates, use the page ordering rules to put the page numbers in the right order. For the above example, here are the three incorrectly-ordered updates and their correct orderings:
  #
  #     75,97,47,61,53 becomes 97,75,47,61,53.
  #     61,13,29 becomes 61,29,13.
  #     97,13,75,29,47 becomes 97,75,47,29,13.
  #
  # After taking only the incorrectly-ordered updates and ordering them correctly, their middle page numbers are 47, 29, and 47. Adding these together produces 123.
  #
  # Find the updates which are not in the correct order. What do you get if you add up the middle page numbers after correctly ordering just those updates?
  #
  # Your puzzle answer was 4922.

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
