defmodule AdventOfCode.Day10 do
  import AdventOfCode.Utils

  # --- Day 10: Hoof It ---
  #
  # You all arrive at a Lava Production Facility on a floating island in the sky. As the others begin to search the massive industrial complex, you feel a small nose boop your leg and look down to discover a reindeer wearing a hard hat.
  #
  # The reindeer is holding a book titled "Lava Island Hiking Guide". However, when you open the book, you discover that most of it seems to have been scorched by lava! As you're about to ask how you can help, the reindeer brings you a blank topographic map of the surrounding area (your puzzle input) and looks up at you excitedly.
  #
  # Perhaps you can help fill in the missing hiking trails?
  #
  # The topographic map indicates the height at each position using a scale from 0 (lowest) to 9 (highest). For example:
  #
  # 0123
  # 1234
  # 8765
  # 9876
  #
  # Based on un-scorched scraps of the book, you determine that a good hiking trail is as long as possible and has an even, gradual, uphill slope. For all practical purposes, this means that a hiking trail is any path that starts at height 0, ends at height 9, and always increases by a height of exactly 1 at each step. Hiking trails never include diagonal steps - only up, down, left, or right (from the perspective of the map).
  #
  # You look up from the map and notice that the reindeer has helpfully begun to construct a small pile of pencils, markers, rulers, compasses, stickers, and other equipment you might need to update the map with hiking trails.
  #
  # A trailhead is any position that starts one or more hiking trails - here, these positions will always have height 0. Assembling more fragments of pages, you establish that a trailhead's score is the number of 9-height positions reachable from that trailhead via a hiking trail. In the above example, the single trailhead in the top left corner has a score of 1 because it can reach a single 9 (the one in the bottom left).
  #
  # This trailhead has a score of 2:
  #
  # ...0...
  # ...1...
  # ...2...
  # 6543456
  # 7.....7
  # 8.....8
  # 9.....9
  #
  # (The positions marked . are impassable tiles to simplify these examples; they do not appear on your actual topographic map.)
  #
  # This trailhead has a score of 4 because every 9 is reachable via a hiking trail except the one immediately to the left of the trailhead:
  #
  # ..90..9
  # ...1.98
  # ...2..7
  # 6543456
  # 765.987
  # 876....
  # 987....
  #
  # This topographic map contains two trailheads; the trailhead at the top has a score of 1, while the trailhead at the bottom has a score of 2:
  #
  # 10..9..
  # 2...8..
  # 3...7..
  # 4567654
  # ...8..3
  # ...9..2
  # .....01
  #
  # Here's a larger example:
  #
  # 89010123
  # 78121874
  # 87430965
  # 96549874
  # 45678903
  # 32019012
  # 01329801
  # 10456732
  #
  # This larger example has 9 trailheads. Considering the trailheads in reading order, they have scores of 5, 6, 5, 3, 1, 3, 5, 3, and 5. Adding these scores together, the sum of the scores of all trailheads is 36.
  #
  # The reindeer gleefully carries over a protractor and adds it to the pile. What is the sum of the scores of all trailheads on your topographic map?
  #
  # Your puzzle answer was 501.

  def calculate_sum_of_trailhead_scores(input) do
    input
    |> parse_grid(&String.to_integer/1)
    |> init()
    |> find_trails()
    |> calculate_trialhead_scores()
    |> sum_trialhead_measurments()
  end

  # --- Part Two ---
  #
  # The reindeer spends a few minutes reviewing your hiking trail map before realizing something, disappearing for a few minutes, and finally returning with yet another slightly-charred piece of paper.
  #
  # The paper describes a second way to measure a trailhead called its rating. A trailhead's rating is the number of distinct hiking trails which begin at that trailhead. For example:
  #
  # .....0.
  # ..4321.
  # ..5..2.
  # ..6543.
  # ..7..4.
  # ..8765.
  # ..9....
  #
  # The above map has a single trailhead; its rating is 3 because there are exactly three distinct hiking trails which begin at that position:
  #
  # .....0.   .....0.   .....0.
  # ..4321.   .....1.   .....1.
  # ..5....   .....2.   .....2.
  # ..6....   ..6543.   .....3.
  # ..7....   ..7....   .....4.
  # ..8....   ..8....   ..8765.
  # ..9....   ..9....   ..9....
  #
  # Here is a map containing a single trailhead with rating 13:
  #
  # ..90..9
  # ...1.98
  # ...2..7
  # 6543456
  # 765.987
  # 876....
  # 987....
  #
  # This map contains a single trailhead with rating 227 (because there are 121 distinct hiking trails that lead to the 9 on the right edge and 106 that lead to the 9 on the bottom edge):
  #
  # 012345
  # 123456
  # 234567
  # 345678
  # 4.6789
  # 56789.
  #
  # Here's the larger example from before:
  #
  # 89010123
  # 78121874
  # 87430965
  # 96549874
  # 45678903
  # 32019012
  # 01329801
  # 10456732
  #
  # Considering its trailheads in reading order, they have ratings of 20, 24, 10, 4, 1, 4, 5, 8, and 5. The sum of all trailhead ratings in this larger example topographic map is 81.
  #
  # You're not sure how, but the reindeer seems to have crafted some tiny flags out of toothpicks and bits of paper and is using them to mark trailheads on your topographic map. What is the sum of the ratings of all trailheads?
  #
  # Your puzzle answer was 1017.

  def calculate_sum_of_trailhead_ratings(input) do
    input
    |> parse_grid(&String.to_integer/1)
    |> init()
    |> find_trails()
    |> calculate_trialhead_ratings()
    |> sum_trialhead_measurments()
  end

  defp sum_trialhead_measurments(scores) do
    Map.values(scores) |> sum()
  end

  defp calculate_trialhead_ratings({_grid, state}) do
    state.trails
    |> Enum.map(fn {trailhead, trails} ->
      {trailhead, length(trails)}
    end)
    |> Enum.into(%{})
  end

  # This confused me a bit, but the score is the number of trails
  # connecting a trailhead to a distinct summit.
  # In other words, the number of trails between a trailhead and a summit
  # isn't important. What is important is to how many summits a trialhead
  # is connected to.
  defp calculate_trialhead_scores({_grid, state}) do
    state.trails
    |> Enum.map(fn {trailhead, trails} ->
      score =
        trails
        |> Enum.map(&Enum.at(&1, -1))
        |> Enum.uniq()
        |> length()

      {trailhead, score}
    end)
    |> Enum.into(%{})
  end

  defp find_trails({grid, state}) do
    trails =
      Task.async_stream(state.trailheads, fn trailhead ->
        new_trails =
          find_trails_from(grid, trailhead)
          |> List.flatten()
          |> Enum.map(fn
            {:ok, trail} -> trail
            _ -> nil
          end)
          |> Enum.filter(&is_list/1)

        {trailhead, new_trails}
      end)
      |> Stream.map(fn
        {:ok, result} -> result
        _ -> nil
      end)
      |> Stream.reject(&is_nil/1)
      |> Enum.to_list()
      |> Enum.into(%{})

    state = %{state | trails: trails}

    {grid, state}
  end

  defp find_trails_from(grid, {x, y} = point, path \\ []) do
    current_elevation = lookup(grid, point)

    last_position =
      case path do
        [] -> nil
        _ -> hd(path)
      end

    if current_elevation < 9 do
      up = {x, y - 1}

      up_paths =
        if lookup(grid, up) == current_elevation + 1 and up != last_position do
          find_trails_from(grid, up, [up | path])
        end

      right = {x + 1, y}

      right_paths =
        if lookup(grid, right) == current_elevation + 1 and right != last_position do
          find_trails_from(grid, right, [right | path])
        end

      down = {x, y + 1}

      down_paths =
        if lookup(grid, down) == current_elevation + 1 and down != last_position do
          find_trails_from(grid, down, [down | path])
        end

      left = {x - 1, y}

      left_paths =
        if lookup(grid, left) == current_elevation + 1 and left != last_position do
          find_trails_from(grid, left, [left | path])
        end

      [up_paths, right_paths, down_paths, left_paths]
      |> Enum.reject(&is_nil/1)
    else
      {:ok, Enum.reverse(path)}
    end
  end

  def lookup(grid, {x, y}) do
    cell =
      grid
      |> Enum.find(fn {{x1, y1}, _} -> x1 == x && y1 == y end)

    if cell, do: elem(cell, 1), else: nil
  end

  defp init(grid) do
    state = %{
      trailheads: find_trailheads(grid),
      trails: %{}
    }

    {grid, state}
  end

  defp find_trailheads(grid) do
    grid
    |> Enum.filter(fn {_coords, elevation} -> elevation == 0 end)
    |> Enum.map(&elem(&1, 0))
  end

  # defp visualize_trail(grid, trailhead, trail) do
  #   IO.puts("Visualizing trail: #{inspect(trail)}")
  #
  #   {width, height} = grid_dimensions(grid)
  #   destination = Enum.at(trail, -1)
  #
  #   for y <- 0..height do
  #     for x <- 0..width do
  #       on_trail = Enum.member?(trail, {x, y})
  #       cell = lookup(grid, {x, y})
  #
  #       cond do
  #         trailhead == {x, y} ->
  #           IO.write(
  #             IO.ANSI.light_green_background() <> IO.ANSI.black() <> "#{cell}" <> IO.ANSI.reset()
  #           )
  #
  #         destination == {x, y} ->
  #           IO.write(IO.ANSI.light_red_background() <> "#{cell}" <> IO.ANSI.reset())
  #
  #         on_trail ->
  #           IO.write(
  #             IO.ANSI.light_blue_background() <> IO.ANSI.black() <> "#{cell}" <> IO.ANSI.reset()
  #           )
  #
  #         true ->
  #           IO.write("#{cell}")
  #       end
  #     end
  #
  #     IO.puts("")
  #   end
  #
  #   IO.puts("")
  # end
end
