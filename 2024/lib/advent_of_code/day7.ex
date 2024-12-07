defmodule AdventOfCode.Day7 do
  import AdventOfCode.Utils

  def find_total_calibration_result(input, with_concatenations) do
    input
    |> break_into_rows()
    |> parse_calibration_data()
    |> find_valid_test_values(with_concatenations)
    |> sum_test_values()
  end

  defp sum_test_values(test_values) do
    Enum.reduce(test_values, 0, fn {test_value, _calibration_data, _}, acc ->
      acc + test_value
    end)
  end

  defp find_valid_test_values(calibration_data, with_concatenations) do
    calibration_data
    |> Task.async_stream(
      fn test -> find_valid_operator_placement_for_test(test, with_concatenations) end,
      timeout: :infinity
    )
    |> Stream.filter(&match?({:ok, {:ok, _}}, &1))
    |> Stream.map(fn {:ok, {:ok, value}} -> value end)
    |> Enum.to_list()
  end

  defp find_valid_operator_placement_for_test({test_value, calibration_data}, with_concatenations) do
    # This is a bit clever, hope it doesn't bite me later, but
    # since there are 2 possible operators - + and * - you can
    # think of all the possible combinations of these operators
    # as a binary number where 0 is + and 1 is *.
    #
    # So the total number of possible operator combinations is
    # 2^(n-1) where n is the number of calibration data points.
    #
    # To test all combinations all I have to do is iterate
    # from 0 to 2^(n-1) and convert the number to binary and
    # use that to determine the operator for each calibration.
    #
    # For part 2: Instead of a binary number I can use a trinary
    # number where 0 is +, 1 is * and 2 is ||
    # Everything else stays the same.
    base = if with_concatenations, do: 3, else: 2

    possible_operator_combinations =
      :math.pow(base, length(calibration_data) - 1)
      |> floor()
      |> Kernel.-(1)

    valid_test =
      Enum.reduce(0..possible_operator_combinations, nil, fn
        operator_combination, nil ->
          combination =
            generate_test_combination(calibration_data, operator_combination, base)

          if test_value == solve(combination) do
            {test_value, calibration_data, combination}
          else
            nil
          end

        _, valid_test ->
          valid_test
      end)

    if valid_test do
      {:ok, valid_test}
    else
      {:error, :invalid_test}
    end
  end

  defp solve([la, lo, lb | rest]) do
    lead = solve(la, lo, lb)
    rest = Enum.chunk_every(rest, 2)

    Enum.reduce(rest, lead, fn
      [o, b], a -> solve(a, o, b)
    end)
  end

  defp solve(a, :+, b), do: a + b

  defp solve(a, :*, b), do: a * b

  defp solve(a, :||, b), do: String.to_integer("#{a}#{b}")

  defp solve(_, o, _), do: raise("Invalid operator #{inspect(o)}")

  defp generate_test_combination(calibration_data, combination_number, base) do
    binary =
      combination_number
      |> Integer.to_string(base)
      |> String.pad_leading(length(calibration_data) - 1, "0")

    operators =
      binary
      |> String.split("", trim: true)
      |> Enum.map(fn
        "0" -> :+
        "1" -> :*
        "2" -> :||
      end)

    operators = operators ++ [nil]

    Enum.zip(calibration_data, operators)
    |> Enum.flat_map(fn {calibration_data, operator} ->
      [calibration_data, operator]
    end)
    |> List.delete_at(-1)
  end

  defp parse_calibration_data(rows) when is_list(rows) do
    Enum.map(rows, &parse_calibration_data/1)
  end

  defp parse_calibration_data(row) do
    [test_value, calibration_data] = String.split(row, ":", trim: true)
    calibration_data = String.split(calibration_data, " ", trim: true)

    test_data = String.to_integer(test_value)
    calibration_data = Enum.map(calibration_data, &String.to_integer/1)

    {test_data, calibration_data}
  end
end
