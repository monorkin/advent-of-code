defmodule AdventOfCode.Day3 do
  import AdventOfCode.Utils

  @uncurrupted_muls_regex ~r/mul\((\d{1,3}),(\d{1,3})\)/
  @uncurrupted_muls_and_conditionals_regex ~r/mul\((\d{1,3}),(\d{1,3})\)|do\(\)|don't\(\)/

  def execute_uncorrupted_muls(input) do
    result =
      input
      |> scan(@uncurrupted_muls_regex)
      |> parse_instructions()
      |> select_instructions(:mul)
      |> execute()

    if result.error do
      nil
    else
      result.results
      |> sum()
    end
  end

  def execute_uncorrupted_with_conditionals_muls(input) do
    result =
      input
      |> scan(@uncurrupted_muls_and_conditionals_regex)
      |> parse_instructions()
      |> execute()

    if result.error do
      nil
    else
      result.results
      |> sum()
    end
  end

  defp parse_instructions(matches) do
    Enum.map(
      matches,
      fn
        ["mul(" <> _, a, b] ->
          {:mul, [String.to_integer(a), String.to_integer(b)]}

        ["do(" <> _] ->
          {:do, []}

        ["don't(" <> _] ->
          {:dont, []}
      end
    )
  end

  defp select_instructions(instructions, type) do
    instructions
    |> Enum.filter(fn
      {^type, _} -> true
      _ -> false
    end)
  end

  def execute(instructions) when is_list(instructions) do
    instructions
    |> Enum.reduce(
      %{error: nil, results: [], ignore_instructions: false},
      fn
        instruction, %{error: nil} = state ->
          case execute(instruction) do
            {:ok, :ignore_instructions} ->
              %{state | ignore_instructions: true}

            {:ok, :execute_instructions} ->
              %{state | ignore_instructions: false}

            {:ok, result} ->
              if state.ignore_instructions do
                state
              else
                %{state | results: [result | state.results]}
              end

            {:error, error} ->
              %{state | error: error}
          end

        _, state ->
          state
      end
    )
  end

  def execute({:mul, [a, b]}), do: {:ok, a * b}

  def execute({:do, _}), do: {:ok, :execute_instructions}

  def execute({:dont, _}), do: {:ok, :ignore_instructions}
end
