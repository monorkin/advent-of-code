# Advent Of Code 2024 - Elixir

Solutions are in `/lib/advent_of_code/day*.ex` files.
Each solution has a corresponding test in `/test/advent_of_code/day*_test.exs` file.

Each solution module contains the text of the puzzle for that day as a comment.
Solutions sometimes contain also explanatory comments for "clever" solutions.

Inputs, including examples, are in `/priv/inputs/day*` directories.

Provided examples are always named `example-{number}.txt` (e.g. `example-1.txt`) 
while any additional examples are named `example-*.txt` (e.g. `example-edgecase.txt`.

Inputs are always named `input-{number}.txt` (e.g. `input-1.txt`).

If the puzzle uses the same input, or the same example, for both parts then 
just one file - the first one - is provided.

## Solutions

Day 1:

```elixir
{:ok, input} = File.read("priv/inputs/day01/input-1.txt")

AdventOfCode.Day01.calculate_total_distance(input)
|> IO.inspect(label: "Part 1")

AdventOfCode.Day01.calculate_similarity_score(input)
|> IO.inspect(label: "Part 2")
```

Day 2:

```elixir
{:ok, input} = File.read("priv/inputs/day02/input-1.txt")

AdventOfCode.Day02.count_safe_reports(input, false)
|> IO.inspect(label: "Part 1")

AdventOfCode.Day02.count_safe_reports(input, true)
|> IO.inspect(label: "Part 2")
```

Day 3:

```elixir
{:ok, input} = File.read("priv/inputs/day03/input-1.txt")

AdventOfCode.Day03.execute_uncorrupted_muls(input)
|> IO.inspect(label: "Part 1")

AdventOfCode.Day03.execute_uncorrupted_with_conditionals_muls(input)
|> IO.inspect(label: "Part 2")
```

Day 4:

```elixir
{:ok, input} = File.read("priv/inputs/day04/input-1.txt")

AdventOfCode.Day04.find_all_occurances_of_xmas(input)
|> IO.inspect(label: "Part 1")

AdventOfCode.Day04.find_all_occurances_of_mas_in_the_shape_of_an_x(input)
|> IO.inspect(label: "Part 2")
```

Day 5:

```elixir
{:ok, input} = File.read("priv/inputs/day05/input-1.txt")

AdventOfCode.Day05.sum_of_correct_middle_pages(input)
|> IO.inspect(label: "Part 1")

AdventOfCode.Day05.sum_of_corrected_middle_pages(input)
|> IO.inspect(label: "Part 2")
```

Day 6:

```elixir
{:ok, input} = File.read("priv/inputs/day06/input-1.txt")

AdventOfCode.Day06.count_distinctive_guard_patrol_positions(input)
|> IO.inspect(label: "Part 1")

AdventOfCode.Day06.count_possible_object_locations_that_cause_a_loop(input)
|> IO.inspect(label: "Part 2")
```

Day 7:

```elixir
{:ok, input} = File.read("priv/inputs/day07/input-1.txt")

AdventOfCode.Day07.find_total_calibration_result(input, false)
|> IO.inspect(label: "Part 1")

AdventOfCode.Day07.find_total_calibration_result(input, true)
|> IO.inspect(label: "Part 2")
```

Day 8:

```elixir
{:ok, input} = File.read("priv/inputs/day08/input-1.txt")

AdventOfCode.Day08.antinodes_count_without_harmonics(input)
|> IO.inspect(label: "Part 1")

AdventOfCode.Day08.antinodes_count_with_harmonics(input)
|> IO.inspect(label: "Part 2")
```

Day 9:

```elixir
{:ok, input} = File.read("priv/inputs/day09/input-1.txt")

AdventOfCode.Day09.fs_checksum_after_compaction(input)
|> IO.inspect(label: "Part 1")

AdventOfCode.Day09.fs_checksum_after_defragmentation(input)
|> IO.inspect(label: "Part 2")
```

Day 10:

```elixir
{:ok, input} = File.read("priv/inputs/day10/input-1.txt")

AdventOfCode.Day10.calculate_sum_of_trailhead_scores(input)
|> IO.inspect(label: "Part 1")

AdventOfCode.Day10.calculate_sum_of_trailhead_ratings(input)
|> IO.inspect(label: "Part 2")
```

Day 11:

```elixir
{:ok, input} = File.read("priv/inputs/day11/input-1.txt")

AdventOfCode.Day11.count_stone_arrangements_after(input, 25)
|> IO.inspect(label: "Part 1")

AdventOfCode.Day11.count_stone_arrangements_after(input, 75)
|> IO.inspect(label: "Part 2")
```

Day 12:

```elixir
{:ok, input} = File.read("priv/inputs/day12/input-1.txt")

AdventOfCode.Day12.calculate_total_fencing_price(input, false)
|> IO.inspect(label: "Part 1")

AdventOfCode.Day12.calculate_total_fencing_price(input, true)
|> IO.inspect(label: "Part 2")
```

Day 13:

```elixir
{:ok, input} = File.read("priv/inputs/day13/input-1.txt")

AdventOfCode.Day13.find_fewest_number_of_tokens_needed_to_win_all_prizes(input, 0)
|> IO.inspect(label: "Part 1")

AdventOfCode.Day13.find_fewest_number_of_tokens_needed_to_win_all_prizes(input, 10_000_000_000_000)
|> IO.inspect(label: "Part 2")
```
