defmodule AdventOfCode.Utils do
  def break_into_rows(input), do: String.split(input, "\n", trim: true)

  def break_into_rows(input, true) do
    String.split(input, "\n")
    |> Enum.map(&String.trim/1)
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

  def sign(n) when n > 0, do: 1

  def sign(n) when n < 0, do: -1

  def sign(_), do: 0
end
