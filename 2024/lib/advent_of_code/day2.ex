defmodule AdventOfCode.Day2 do
  import AdventOfCode.Utils

  # --- Day 2: Red-Nosed Reports ---
  #
  # Fortunately, the first location The Historians want to search isn't a long walk from the Chief Historian's office.
  #
  # While the Red-Nosed Reindeer nuclear fusion/fission plant appears to contain no sign of the Chief Historian, the engineers there run up to you as soon as they see you. Apparently, they still talk about the time Rudolph was saved through molecular synthesis from a single electron.
  #
  # They're quick to add that - since you're already here - they'd really appreciate your help analyzing some unusual data from the Red-Nosed reactor. You turn to check if The Historians are waiting for you, but they seem to have already divided into groups that are currently searching every corner of the facility. You offer to help with the unusual data.
  #
  # The unusual data (your puzzle input) consists of many reports, one report per line. Each report is a list of numbers called levels that are separated by spaces. For example:
  #
  # 7 6 4 2 1
  # 1 2 7 8 9
  # 9 7 6 2 1
  # 1 3 2 4 5
  # 8 6 4 4 1
  # 1 3 6 7 9
  #
  # This example data contains six reports each containing five levels.
  #
  # The engineers are trying to figure out which reports are safe. The Red-Nosed reactor safety systems can only tolerate levels that are either gradually increasing or gradually decreasing. So, a report only counts as safe if both of the following are true:
  #
  #     The levels are either all increasing or all decreasing.
  #     Any two adjacent levels differ by at least one and at most three.
  #
  # In the example above, the reports can be found safe or unsafe by checking those rules:
  #
  #     7 6 4 2 1: Safe because the levels are all decreasing by 1 or 2.
  #     1 2 7 8 9: Unsafe because 2 7 is an increase of 5.
  #     9 7 6 2 1: Unsafe because 6 2 is a decrease of 4.
  #     1 3 2 4 5: Unsafe because 1 3 is increasing but 3 2 is decreasing.
  #     8 6 4 4 1: Unsafe because 4 4 is neither an increase or a decrease.
  #     1 3 6 7 9: Safe because the levels are all increasing by 1, 2, or 3.
  #
  # So, in this example, 2 reports are safe.
  #
  # Analyze the unusual data from the engineers. How many reports are safe?
  #
  # Your puzzle answer was 516.
  # --- Part Two ---
  #
  # The engineers are surprised by the low number of safe reports until they realize they forgot to tell you about the Problem Dampener.
  #
  # The Problem Dampener is a reactor-mounted module that lets the reactor safety systems tolerate a single bad level in what would otherwise be a safe report. It's like the bad level never happened!
  #
  # Now, the same rules apply as before, except if removing a single level from an unsafe report would make it safe, the report instead counts as safe.
  #
  # More of the above example's reports are now safe:
  #
  #     7 6 4 2 1: Safe without removing any level.
  #     1 2 7 8 9: Unsafe regardless of which level is removed.
  #     9 7 6 2 1: Unsafe regardless of which level is removed.
  #     1 3 2 4 5: Safe by removing the second level, 3.
  #     8 6 4 4 1: Safe by removing the third level, 4.
  #     1 3 6 7 9: Safe without removing any level.
  #
  # Thanks to the Problem Dampener, 4 reports are actually safe!
  #
  # Update your analysis by handling situations where the Problem Dampener can remove a single level from unsafe reports. How many reports are now safe?
  #
  # Your puzzle answer was 561.

  def count_safe_reports(input, with_problem_dampener) do
    input
    |> break_into_rows()
    |> convert_rows_to_integers()
    |> asses_safety_of_each_report(with_problem_dampener)
    |> Enum.count(fn {safe, _reason, _report} -> safe == :safe end)
  end

  defp asses_safety_of_each_report(rows, with_problem_dampener) do
    Enum.map(rows, fn row ->
      {safety, reason} = asses_safety_of_report(row, with_problem_dampener)
      {safety, reason, row}
    end)
  end

  defp asses_safety_of_report(row, true) do
    case asses_safety_of_report(row, false) do
      {:safe, _} = result ->
        result

      {:unsafe, _} ->
        row
        |> create_permutations()
        |> Enum.find(fn permutation ->
          asses_safety_of_report(permutation, false) == {:safe, nil}
        end)
        |> unwrap_or_return(row)
        |> asses_safety_of_report(false)
    end
  end

  defp asses_safety_of_report(row, false) do
    diffs = generate_report_diffs(row)

    case {diffs_within_acceptable_levels?(diffs), diffs_have_the_same_gradient?(diffs)} do
      {true, true} -> {:safe, nil}
      {false, _} -> {:unsafe, :outside_acceptable_levels}
      {_, false} -> {:unsafe, :different_gradient}
    end
  end

  defp create_permutations(row) do
    Stream.map(0..(length(row) - 1), &List.delete_at(row, &1))
  end

  defp generate_report_diffs(row) do
    row
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [x, y] -> x - y end)
  end

  defp diffs_within_acceptable_levels?(diffs) do
    Enum.all?(diffs, &diff_of_acceptable_level?/1)
  end

  defp diff_of_acceptable_level?(diff), do: abs(diff) >= 1 && abs(diff) <= 3

  defp diffs_have_the_same_gradient?([first_diff | diffs]) do
    Enum.all?(diffs, fn diff -> diff * first_diff > 0 end)
  end
end
