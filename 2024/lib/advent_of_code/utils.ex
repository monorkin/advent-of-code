defmodule AdventOfCode.Utils do
  def break_into_rows(input), do: String.split(input, "\n", trim: true)

  def break_into_rows(input, true) do
    String.split(input, "\n")
    |> Enum.map(&String.trim/1)
  end

  def break_into_row_of(string, converter \\ & &1) do
    string
    |> String.split(" ", trim: true)
    |> Enum.map(fn elem -> elem |> String.trim() |> converter.() end)
  end

  def sum(list), do: Enum.sum(list)

  def convert_rows_to_integers(rows) do
    Enum.map(rows, fn row ->
      String.split(row, " ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def convert_rows_to_integer_pairs(rows) do
    rows
    |> convert_rows_to_integers()
    |> Enum.map(fn row ->
      [x, y] = row
      {x, y}
    end)
  end

  def unwrap_or_return(nil, return), do: return

  def unwrap_or_return({:error, _}, return), do: return

  def unwrap_or_return(value, _), do: value

  def scan(input, regex, options \\ []) do
    Regex.scan(regex, input, options)
  end

  def replace(input, regex, replacement, options \\ []) do
    Regex.replace(regex, input, replacement, options)
  end

  def sign(n) when n > 0, do: 1

  def sign(n) when n < 0, do: -1

  def sign(_), do: 0

  def find_last(list, matcher) do
    case _find_last(list, matcher, length(list) - 1) do
      {elem, _} -> elem
      _ -> nil
    end
  end

  def find_last_index(list, matcher) do
    _find_last(list, matcher, length(list) - 1)
  end

  defp _find_last(_list, _matcher, i) when i < 0, do: nil

  defp _find_last(list, matcher, i) do
    elem = Enum.at(list, i)

    if matcher.(elem) do
      {elem, i}
    else
      _find_last(list, matcher, i - 1)
    end
  end

  def find_index(list, matcher) do
    case Enum.find_index(list, matcher) do
      nil -> nil
      i -> {Enum.at(list, i), i}
    end
  end

  def parse_grid(input, converter \\ & &1) do
    input
    |> break_into_rows()
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, y}, acc ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {cell, x}, acc ->
        acc
        |> Map.put({x, y}, converter.(cell))
      end)
    end)
  end

  def grid_dimensions(grid) do
    width = grid |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.max()
    height = grid |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.max()
    {width, height}
  end
end
