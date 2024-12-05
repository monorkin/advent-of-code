# Advent Of Code 2024 - Elixir

Solutions are in `/lib/advent_of_code/day*.ex` files.
Each solution has a corresponding test in `/test/advent_of_code/day*_test.exs` file.

Inputs, including examples, are in `/priv/inputs/day*` directories.

Provided examples are always named `example-{number}.txt` (e.g. `example-1.txt`) 
while any additional examples are named `example-*.txt` (e.g. `example-edgecase.txt`.

Inputs are always named `input-{number}.txt` (e.g. `input-1.txt`).

If the puzzle uses the same input, or the same example, for both parts then 
just one file - the first one - is provided.

## Solutions

Day 1:

```elixir
{:ok, input} = File.read("priv/inputs/day1/input-1.txt")

AdventOfCode.Day1.calculate_total_distance(input)
|> IO.inspect(label: "Part 1")

AdventOfCode.Day1.calculate_similarity_score(input)
|> IO.inspect(label: "Part 2")
```

Day 2:

```elixir
{:ok, input} = File.read("priv/inputs/day2/input-1.txt")

AdventOfCode.Day2.count_safe_reports(input, false)
|> IO.inspect(label: "Part 1")

AdventOfCode.Day2.count_safe_reports(input, true)
|> IO.inspect(label: "Part 2")
```

Day 3:

```elixir
{:ok, input} = File.read("priv/inputs/day3/input-1.txt")

AdventOfCode.Day3.execute_uncorrupted_muls(input)
|> IO.inspect(label: "Part 1")

AdventOfCode.Day3.execute_uncorrupted_with_conditionals_muls(input)
|> IO.inspect(label: "Part 2")
```

Day 4:

```elixir
{:ok, input} = File.read("priv/inputs/day4/input-1.txt")

AdventOfCode.Day4.find_all_occurances_of_xmas(input)
|> IO.inspect(label: "Part 1")

AdventOfCode.Day4.find_all_occurances_of_mas_in_the_shape_of_an_x(input)
|> IO.inspect(label: "Part 2")
```

Day 5:

```elixir
{:ok, input} = File.read("priv/inputs/day5/input-1.txt")

AdventOfCode.Day5.sum_of_correct_middle_pages(input)
|> IO.inspect(label: "Part 1")

AdventOfCode.Day5.sum_of_corrected_middle_pages(input)
|> IO.inspect(label: "Part 2")
```
