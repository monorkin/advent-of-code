defmodule AdventOfCode.Day11 do
  import AdventOfCode.Utils

  # --- Day 11: Plutonian Pebbles ---
  #
  # The ancient civilization on Pluto was known for its ability to manipulate spacetime, and while The Historians explore their infinite corridors, you've noticed a strange set of physics-defying stones.
  #
  # At first glance, they seem like normal stones: they're arranged in a perfectly straight line, and each stone has a number engraved on it.
  #
  # The strange part is that every time you blink, the stones change.
  #
  # Sometimes, the number engraved on a stone changes. Other times, a stone might split in two, causing all the other stones to shift over a bit to make room in their perfectly straight line.
  #
  # As you observe them for a while, you find that the stones have a consistent behavior. Every time you blink, the stones each simultaneously change according to the first applicable rule in this list:
  #
  #     If the stone is engraved with the number 0, it is replaced by a stone engraved with the number 1.
  #     If the stone is engraved with a number that has an even number of digits, it is replaced by two stones. The left half of the digits are engraved on the new left stone, and the right half of the digits are engraved on the new right stone. (The new numbers don't keep extra leading zeroes: 1000 would become stones 10 and 0.)
  #     If none of the other rules apply, the stone is replaced by a new stone; the old stone's number multiplied by 2024 is engraved on the new stone.
  #
  # No matter how the stones change, their order is preserved, and they stay on their perfectly straight line.
  #
  # How will the stones evolve if you keep blinking at them? You take a note of the number engraved on each stone in the line (your puzzle input).
  #
  # If you have an arrangement of five stones engraved with the numbers 0 1 10 99 999 and you blink once, the stones transform as follows:
  #
  #     The first stone, 0, becomes a stone marked 1.
  #     The second stone, 1, is multiplied by 2024 to become 2024.
  #     The third stone, 10, is split into a stone marked 1 followed by a stone marked 0.
  #     The fourth stone, 99, is split into two stones marked 9.
  #     The fifth stone, 999, is replaced by a stone marked 2021976.
  #
  # So, after blinking once, your five stones would become an arrangement of seven stones engraved with the numbers 1 2024 1 0 9 9 2021976.
  #
  # Here is a longer example:
  #
  # Initial arrangement:
  # 125 17
  #
  # After 1 blink:
  # 253000 1 7
  #
  # After 2 blinks:
  # 253 0 2024 14168
  #
  # After 3 blinks:
  # 512072 1 20 24 28676032
  #
  # After 4 blinks:
  # 512 72 2024 2 0 2 4 2867 6032
  #
  # After 5 blinks:
  # 1036288 7 2 20 24 4048 1 4048 8096 28 67 60 32
  #
  # After 6 blinks:
  # 2097446912 14168 4048 2 0 2 4 40 48 2024 40 48 80 96 2 8 6 7 6 0 3 2
  #
  # In this example, after blinking six times, you would have 22 stones. After blinking 25 times, you would have 55312 stones!
  #
  # Consider the arrangement of stones in front of you. How many stones will you have after blinking 25 times?
  #
  # Your puzzle answer was 212655.
  #
  # The first half of this puzzle is complete! It provides one gold star: *
  #
  # --- Part Two ---
  #
  # The Historians sure are taking a long time. To be fair, the infinite corridors are very large.
  #
  # How many stones would you have after blinking a total of 75 times?
  #
  # Your puzzle answer was 253582809724830.

  def count_stone_arrangements_after(input, blinks) do
    input
    |> break_into_row_of(&String.to_integer/1)
    |> stone_count_after_blinks(blinks)
  end

  defp stone_count_after_blinks(stones, blinks) when is_list(stones) do
    # Prefill the lookup map so that we can have as many cache hits as possible
    # We start with 1 because it gives us 1 more count "for free" since we know that
    # because the 0 count for any number of blinks is the same as the 1 count + 1
    {lookup_map, _} = stone_count_after_blinks(1, blinks, %{})

    zero_lookup_map =
      lookup_map
      |> Map.get(1, %{})
      |> Enum.map(fn {blinks, count} -> {blinks, count + 1} end)
      |> Enum.into(%{})

    zero_lookup_map = Map.merge(zero_lookup_map, Map.get(lookup_map, 0, %{}))

    lookup_map = Map.put_new(lookup_map, 0, zero_lookup_map)

    # The order of the stones doesn't make a differance to the result so we can 
    # freely rearange them.
    # If we sort them before processing we will have a higher chance of hitting
    # the cache, and also of filling the cache with any missing entries
    stones
    |> Enum.sort()
    |> Enum.reduce({0, lookup_map}, fn stone, {count, lookup_map} ->
      {new_lookup_map, sub_count} = stone_count_after_blinks(stone, blinks, lookup_map)
      {count + sub_count, new_lookup_map}
    end)
    |> elem(0)
  end

  # So, running the simulation and counting the result works for lower number of
  # blinks (less than 40) for higher number you'll either wait a loooooong time
  # (if you simulate each step) or run out of memory (if you process each stone
  # and count up the total)
  #
  # The trick to speeding this up is to realize that the transformation/decay of the
  # stones runs in a loop - 0 -> 1 -> 2024 -> 20,24 -> 2,0,2,4 -> ...
  # Since we are only interested in the count of stones after a certain number of blinks
  # and we know that there are numbers that cause loops - like 0, 1, 2, 4, 6, 8, 9, 20, 24, ...
  # we can just precompute their counts at different blink levels, or cache the counts
  # as we discover them.
  #
  # That way, when we encounter such a number, if we have the precomputed count, we can
  # remove the stone from the set of stones and add its precomputed count to the total.
  #
  # This sounds like a small win but it's actually huge because the number of stones
  # grows exponentially with each blink, so any stone that we can remove greatly reduces
  # the number of stones that we have to process.
  #
  # In code terms, this means that I precompute a lookup map that looks like this:
  # ```elixir
  # %{
  #  stone => %{
  #   blinks => count,
  #   blinks => count,
  #   ...
  #  },
  #  ...
  # }
  # ```
  # And in each iteration I check if I have a precomputed count for the current stone with
  # the current number of blinks.
  # If I do, I remove the stone from the set of stones and
  # add the precomputed count to the total.
  # If I don't I compute the count and add it to the set.
  defp stone_count_after_blinks(stone, blinks, lookup_map) when blinks <= 0 do
    lookup_map = Map.put_new(lookup_map, stone, %{})
    lookup_map = put_in(lookup_map, [stone, 0], 1)

    {lookup_map, 1}
  end

  defp stone_count_after_blinks(stone, blinks, lookup_map) do
    lookup_map = Map.put_new(lookup_map, stone, %{})
    cached_count = get_in(lookup_map, [stone, blinks])

    if cached_count do
      {lookup_map, cached_count}
    else
      {new_map, count} =
        case apply_rules(stone) do
          {left, right} ->
            {left_map, first_count} = stone_count_after_blinks(left, blinks - 1, lookup_map)
            {new_map, second_count} = stone_count_after_blinks(right, blinks - 1, left_map)
            {new_map, first_count + second_count}

          new_stone ->
            {new_map, sub_count} = stone_count_after_blinks(new_stone, blinks - 1, lookup_map)
            {new_map, sub_count}
        end

      {put_in(new_map, [stone, blinks], count), count}
    end
  end

  defp apply_rules(stone) when is_integer(stone) do
    digits = Integer.digits(stone)

    cond do
      # If the stone is engraved with the number 0, it is replaced by a stone engraved with the number 1.
      stone == 0 ->
        1

      # If the stone is engraved with a number that has an even number of digits, it is replaced by two stones.
      rem(length(digits), 2) == 0 ->
        {
          Integer.undigits(digits |> Enum.take(div(length(digits), 2))),
          Integer.undigits(digits |> Enum.drop(div(length(digits), 2)))
        }

      # If none of the other rules apply, the stone is replaced by a new stone; the old stone's number multiplied by 2024 is engraved on the new stone
      true ->
        stone * 2024
    end
  end
end
