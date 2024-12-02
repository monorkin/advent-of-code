defmodule AdventOfCode.Day1 do
  def calculate_total_distance(input) do
    input
    |> break_into_rows()
    |> convert_rows_to_integer_pairs()
    |> pair_up_smallest_distances()
    |> calculate_differences()
    |> sum()
  end

  def calculate_similarity_score(input) do
    input
    |> break_into_rows()
    |> convert_rows_to_integer_pairs()
    |> calculate_similarity_scores()
    |> sum()
  end

  defp break_into_rows(input), do: String.split(input, "\n", trim: true)

  defp convert_rows_to_integer_pairs(rows) do
    Enum.map(rows, fn row ->
      [x, y] = String.split(row, " ", trim: true)
      {String.to_integer(x), String.to_integer(y)}
    end)
  end

  defp pair_up_smallest_distances(pairs) do
    left = Enum.map(pairs, fn {x, _} -> x end) |> Enum.sort()
    right = Enum.map(pairs, fn {_, y} -> y end) |> Enum.sort()

    Enum.zip(left, right)
  end

  defp calculate_differences(pairs) do
    Enum.map(pairs, fn {x, y} -> abs(x - y) end)
  end

  defp sum(list), do: Enum.sum(list)

  defp calculate_similarity_scores(pairs) do
    left = Enum.map(pairs, fn {x, _} -> x end)
    right = Enum.map(pairs, fn {_, y} -> y end)
    tally = Enum.frequencies(right)

    Enum.map(left, fn x -> x * (tally[x] || 0) end)
  end
end
