defmodule AdventOfCode.Day2 do
  import AdventOfCode.Utils

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
