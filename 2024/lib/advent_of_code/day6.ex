defmodule AdventOfCode.Day6 do
  import AdventOfCode.Utils

  # --- Day 6: Guard Gallivant ---
  #
  # The Historians use their fancy device again, this time to whisk you all away to the North Pole prototype suit manufacturing lab... in the year 1518! It turns out that having direct access to history is very convenient for a group of historians.
  #
  # You still have to be careful of time paradoxes, and so it will be important to avoid anyone from 1518 while The Historians search for the Chief. Unfortunately, a single guard is patrolling this part of the lab.
  #
  # Maybe you can work out where the guard will go ahead of time so that The Historians can search safely?
  #
  # You start by making a map (your puzzle input) of the situation. For example:
  #
  # ....#.....
  # .........#
  # ..........
  # ..#.......
  # .......#..
  # ..........
  # .#..^.....
  # ........#.
  # #.........
  # ......#...
  #
  # The map shows the current position of the guard with ^ (to indicate the guard is currently facing up from the perspective of the map). Any obstructions - crates, desks, alchemical reactors, etc. - are shown as #.
  #
  # Lab guards in 1518 follow a very strict patrol protocol which involves repeatedly following these steps:
  #
  #     If there is something directly in front of you, turn right 90 degrees.
  #     Otherwise, take a step forward.
  #
  # Following the above protocol, the guard moves up several times until she reaches an obstacle (in this case, a pile of failed suit prototypes):
  #
  # ....#.....
  # ....^....#
  # ..........
  # ..#.......
  # .......#..
  # ..........
  # .#........
  # ........#.
  # #.........
  # ......#...
  #
  # Because there is now an obstacle in front of the guard, she turns right before continuing straight in her new facing direction:
  #
  # ....#.....
  # ........>#
  # ..........
  # ..#.......
  # .......#..
  # ..........
  # .#........
  # ........#.
  # #.........
  # ......#...
  #
  # Reaching another obstacle (a spool of several very long polymers), she turns right again and continues downward:
  #
  # ....#.....
  # .........#
  # ..........
  # ..#.......
  # .......#..
  # ..........
  # .#......v.
  # ........#.
  # #.........
  # ......#...
  #
  # This process continues for a while, but the guard eventually leaves the mapped area (after walking past a tank of universal solvent):
  #
  # ....#.....
  # .........#
  # ..........
  # ..#.......
  # .......#..
  # ..........
  # .#........
  # ........#.
  # #.........
  # ......#v..
  #
  # By predicting the guard's route, you can determine which specific positions in the lab will be in the patrol path. Including the guard's starting position, the positions visited by the guard before leaving the area are marked with an X:
  #
  # ....#.....
  # ....XXXXX#
  # ....X...X.
  # ..#.X...X.
  # ..XXXXX#X.
  # ..X.X.X.X.
  # .#XXXXXXX.
  # .XXXXXXX#.
  # #XXXXXXX..
  # ......#X..
  #
  # In this example, the guard will visit 41 distinct positions on your map.
  #
  # Predict the path of the guard. How many distinct positions will the guard visit before leaving the mapped area?
  #
  # Your puzzle answer was 4776.

  def count_distinctive_guard_patrol_positions(input) do
    input
    |> break_into_rows()
    |> parse_map()
    |> simulate_patrol()
    |> count_visited_tiles()
  end

  # --- Part Two ---
  #
  # While The Historians begin working around the guard's patrol route, you borrow their fancy device and step outside the lab. From the safety of a supply closet, you time travel through the last few months and record the nightly status of the lab's guard post on the walls of the closet.
  #
  # Returning after what seems like only a few seconds to The Historians, they explain that the guard's patrol area is simply too large for them to safely search the lab without getting caught.
  #
  # Fortunately, they are pretty sure that adding a single new obstruction won't cause a time paradox. They'd like to place the new obstruction in such a way that the guard will get stuck in a loop, making the rest of the lab safe to search.
  #
  # To have the lowest chance of creating a time paradox, The Historians would like to know all of the possible positions for such an obstruction. The new obstruction can't be placed at the guard's starting position - the guard is there right now and would notice.
  #
  # In the above example, there are only 6 different positions where a new obstruction would cause the guard to get stuck in a loop. The diagrams of these six situations use O to mark the new obstruction, | to show a position where the guard moves up/down, - to show a position where the guard moves left/right, and + to show a position where the guard moves both up/down and left/right.
  #
  # Option one, put a printing press next to the guard's starting position:
  #
  # ....#.....
  # ....+---+#
  # ....|...|.
  # ..#.|...|.
  # ....|..#|.
  # ....|...|.
  # .#.O^---+.
  # ........#.
  # #.........
  # ......#...
  #
  # Option two, put a stack of failed suit prototypes in the bottom right quadrant of the mapped area:
  #
  # ....#.....
  # ....+---+#
  # ....|...|.
  # ..#.|...|.
  # ..+-+-+#|.
  # ..|.|.|.|.
  # .#+-^-+-+.
  # ......O.#.
  # #.........
  # ......#...
  #
  # Option three, put a crate of chimney-squeeze prototype fabric next to the standing desk in the bottom right quadrant:
  #
  # ....#.....
  # ....+---+#
  # ....|...|.
  # ..#.|...|.
  # ..+-+-+#|.
  # ..|.|.|.|.
  # .#+-^-+-+.
  # .+----+O#.
  # #+----+...
  # ......#...
  #
  # Option four, put an alchemical retroencabulator near the bottom left corner:
  #
  # ....#.....
  # ....+---+#
  # ....|...|.
  # ..#.|...|.
  # ..+-+-+#|.
  # ..|.|.|.|.
  # .#+-^-+-+.
  # ..|...|.#.
  # #O+---+...
  # ......#...
  #
  # Option five, put the alchemical retroencabulator a bit to the right instead:
  #
  # ....#.....
  # ....+---+#
  # ....|...|.
  # ..#.|...|.
  # ..+-+-+#|.
  # ..|.|.|.|.
  # .#+-^-+-+.
  # ....|.|.#.
  # #..O+-+...
  # ......#...
  #
  # Option six, put a tank of sovereign glue right next to the tank of universal solvent:
  #
  # ....#.....
  # ....+---+#
  # ....|...|.
  # ..#.|...|.
  # ..+-+-+#|.
  # ..|.|.|.|.
  # .#+-^-+-+.
  # .+----++#.
  # #+----++..
  # ......#O..
  #
  # It doesn't really matter what you choose to use as an obstacle so long as you and The Historians can put it into position without the guard noticing. The important thing is having enough options that you can find one that minimizes time paradoxes, and in this example, there are 6 different positions you could choose.
  #
  # You need to get the guard stuck in a loop by adding a single new obstruction. How many different positions could you choose for this obstruction?
  #
  # Your puzzle answer was 1586.

  def count_possible_object_locations_that_cause_a_loop(input) do
    input
    |> break_into_rows()
    |> parse_map()
    |> simulate_patrol()
    |> find_potential_loop_locations()
    |> select_obstacles_that_form_loops()
    |> length()
  end

  defp find_potential_loop_locations({map, guard, state}) do
    {gx, gy, _} = state.initial_guard

    potential_loop_obsticle_locations =
      state.path
      |> Enum.reverse()
      |> Enum.map(fn {x, y, _} ->
        {x, y}
      end)
      |> Enum.uniq()
      |> Enum.reject(fn {x, y} -> gx == x && gy == y end)

    {map, guard, state, potential_loop_obsticle_locations}
  end

  defp select_obstacles_that_form_loops(
         {map, _guard, initial_state, potential_loop_obsticle_locations}
       ) do
    potential_loop_obsticle_locations
    |> Task.async_stream(
      fn {x, y} ->
        {_loop_map, _loop_guard, state} =
          simulate_patrol({mark_map(map, {x, y}, :obstacle), initial_state.initial_guard})

        if state.loop do
          {x, y}
        else
          nil
        end
      end,
      timeout: :infinity
    )
    |> Stream.filter(&match?({:ok, value} when not is_nil(value), &1))
    |> Stream.map(fn {:ok, value} -> value end)
    |> Enum.to_list()
  end

  defp count_visited_tiles({_, _, %{path: path}}) do
    path
    |> Enum.map(fn {x, y, _} -> {x, y} end)
    |> Enum.uniq()
    |> Enum.count()
  end

  defp simulate_patrol({map, guard}) do
    simulate_patrol(
      map,
      guard,
      %{
        initial_guard: guard,
        patrol_map: map,
        path: [],
        loop: false,
        out_of_bounds: false
      }
    )
  end

  # The guard went out of bounds so stop the simulation
  defp simulate_patrol(map, guard, %{out_of_bounds: true} = state) do
    {map, guard, state}
  end

  # Let the guard take a step on their patrol
  defp simulate_patrol(map, {_, _, _} = guard, state) do
    if in_a_loop?(state.path, guard) do
      state = Map.put(state, :loop, true)
      {map, guard, state}
    else
      {new_map, new_guard, new_state} =
        perform_simulation_step(map, guard, state)

      simulate_patrol(new_map, new_guard, new_state)
    end
  end

  # If we didn't go anywhere we can't be in a loop
  defp in_a_loop?([], _), do: false

  defp in_a_loop?(path, guard) do
    guard in path
  end

  defp perform_simulation_step(map, {guard_x, guard_y, heading} = guard, state) do
    # Mark visited tile and remeber the guard's path
    state =
      state
      |> Map.update(:path, [], fn p -> [guard | p] end)

    # Take a step in the direction the guard is facing
    case take_step(map, {guard_x, guard_y}, heading) do
      {:ok, next_position_and_heading} ->
        {map, next_position_and_heading, state}

      {:error, :out_of_bounds} ->
        state = Map.put(state, :out_of_bounds, true)
        {map, guard, state}
    end
  end

  defp take_step(map, {x, y}, {dx, dy}) do
    next_x = x + dx
    next_y = y + dy
    next_tile = tile_at(map, {next_x, next_y})

    case next_tile do
      {_, _, :empty} -> {:ok, {next_x, next_y, {dx, dy}}}
      {_, _, :obstacle} -> {:ok, {x, y, turn({dx, dy})}}
      {_, _, :out_of_bounds} -> {:error, :out_of_bounds}
      _ -> raise "Invalid tile '#{inspect(next_tile)}'"
    end
  end

  defp turn(heading) do
    case heading do
      {0, -1} -> {1, 0}
      {1, 0} -> {0, 1}
      {0, 1} -> {-1, 0}
      {-1, 0} -> {0, -1}
    end
  end

  defp tile_at(_, {x, y}) when x < 0 or y < 0 do
    {x, y, :out_of_bounds}
  end

  defp tile_at(map, {x, y}) do
    row = Enum.at(map, y)

    if is_nil(row) do
      {x, y, :out_of_bounds}
    else
      tile = Enum.at(row, x)

      if is_nil(tile) do
        {x, y, :out_of_bounds}
      else
        tile
      end
    end
  end

  defp mark_map(map, {x, y}, tile) do
    Enum.with_index(map)
    |> Enum.map(fn {row, y_index} ->
      Enum.with_index(row)
      |> Enum.map(fn {current_tile, x_index} ->
        if x_index == x and y_index == y do
          {x, y, tile}
        else
          current_tile
        end
      end)
    end)
  end

  defp parse_map(rows) do
    grid =
      rows
      |> Enum.with_index()
      |> Enum.map(fn {row, y} ->
        String.split(row, "", trim: true)
        |> Enum.with_index()
        |> Enum.map(fn {tile, x} ->
          {x, y, parse_tile(tile)}
        end)
      end)

    {guard_x, guard_y, _} =
      grid
      |> Enum.flat_map(&Enum.filter(&1, fn {_x, _y, tile} -> tile == :guard end))
      |> List.first()

    guard_tile =
      rows
      |> Enum.at(guard_y)
      |> String.split("", trim: true)
      |> Enum.at(guard_x)

    grid = mark_map(grid, {guard_x, guard_y}, :empty)

    {grid, {guard_x, guard_y, parse_guard_direction(guard_tile)}}
  end

  defp parse_tile(tile) do
    case tile do
      "." -> :empty
      "#" -> :obstacle
      "^" -> :guard
      ">" -> :guard
      "v" -> :guard
      "<" -> :guard
      _ -> raise "Invalid tile '#{inspect(tile)}'"
    end
  end

  defp parse_guard_direction(guard) do
    case guard do
      "^" -> {0, -1}
      ">" -> {1, 0}
      "v" -> {0, 1}
      "<" -> {-1, 0}
      _ -> raise "Invalid guard direction '#{inspect(guard)}'"
    end
  end
end
