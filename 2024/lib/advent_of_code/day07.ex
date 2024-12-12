defmodule AdventOfCode.Day07 do
  import AdventOfCode.Utils

  # --- Day 7: Bridge Repair ---
  #
  # The Historians take you to a familiar rope bridge over a river in the middle of a jungle. The Chief isn't on this side of the bridge, though; maybe he's on the other side?
  #
  # When you go to cross the bridge, you notice a group of engineers trying to repair it. (Apparently, it breaks pretty frequently.) You won't be able to cross until it's fixed.
  #
  # You ask how long it'll take; the engineers tell you that it only needs final calibrations, but some young elephants were playing nearby and stole all the operators from their calibration equations! They could finish the calibrations if only someone could determine which test values could possibly be produced by placing any combination of operators into their calibration equations (your puzzle input).
  #
  # For example:
  #
  # 190: 10 19
  # 3267: 81 40 27
  # 83: 17 5
  # 156: 15 6
  # 7290: 6 8 6 15
  # 161011: 16 10 13
  # 192: 17 8 14
  # 21037: 9 7 18 13
  # 292: 11 6 16 20
  #
  # Each line represents a single equation. The test value appears before the colon on each line; it is your job to determine whether the remaining numbers can be combined with operators to produce the test value.
  #
  # Operators are always evaluated left-to-right, not according to precedence rules. Furthermore, numbers in the equations cannot be rearranged. Glancing into the jungle, you can see elephants holding two different types of operators: add (+) and multiply (*).
  #
  # Only three of the above equations can be made true by inserting operators:
  #
  #     190: 10 19 has only one position that accepts an operator: between 10 and 19. Choosing + would give 29, but choosing * would give the test value (10 * 19 = 190).
  #     3267: 81 40 27 has two positions for operators. Of the four possible configurations of the operators, two cause the right side to match the test value: 81 + 40 * 27 and 81 * 40 + 27 both equal 3267 (when evaluated left-to-right)!
  #     292: 11 6 16 20 can be solved in exactly one way: 11 + 6 * 16 + 20.
  #
  # The engineers just need the total calibration result, which is the sum of the test values from just the equations that could possibly be true. In the above example, the sum of the test values for the three equations listed above is 3749.
  #
  # Determine which equations could possibly be true. What is their total calibration result?
  #
  # Your puzzle answer was 6392012777720.
  #
  # --- Part Two ---
  #
  # The engineers seem concerned; the total calibration result you gave them is nowhere close to being within safety tolerances. Just then, you spot your mistake: some well-hidden elephants are holding a third type of operator.
  #
  # The concatenation operator (||) combines the digits from its left and right inputs into a single number. For example, 12 || 345 would become 12345. All operators are still evaluated left-to-right.
  #
  # Now, apart from the three equations that could be made true using only addition and multiplication, the above example has three more equations that can be made true by inserting operators:
  #
  #     156: 15 6 can be made true through a single concatenation: 15 || 6 = 156.
  #     7290: 6 8 6 15 can be made true using 6 * 8 || 6 * 15.
  #     192: 17 8 14 can be made true using 17 || 8 + 14.
  #
  # Adding up all six test values (the three that could be made before using only + and * plus the new three that can now be made by also using ||) produces the new total calibration result of 11387.
  #
  # Using your new knowledge of elephant hiding spots, determine which equations could possibly be true. What is their total calibration result?
  #
  # Your puzzle answer was 61561126043536.

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
