defmodule AdventOfCode.Day6 do
  import AdventOfCode.Utils

  def count_distinctive_guard_patrol_positions(input) do
    input
    |> break_into_rows()
    |> parse_map()
    |> simulate_patrol()
    |> count_visited_tiles()
  end

  def count_possible_object_locations_that_cause_a_loop(input) do
    input
    |> break_into_rows()
    |> parse_map()
    |> simulate_patrol()
    |> find_potential_loop_locations()
    |> select_loops()
    |> length()
  end

  # Tried to be smart here and detect crossings as they are the most likely places that a loop would occur
  # The problem with crossings is that there can be loops that don't start at a crossing
  # A loop could start by placing an obstacle on the guards path forcing it to turn and enter a trap
  #
  # defp find_potential_loop_locations({map, guard, state}) do
  #   potential_loop_obsticle_locations =
  #     state.path
  #     |> Enum.frequencies_by(fn {x, y, _} -> {x, y} end)
  #     |> Enum.filter(fn {_, count} -> count > 1 end)
  #     |> Enum.flat_map(fn {{x, y}, _} ->
  #       Enum.filter(state.path, fn {px, py, _} -> px == x && py == y end)
  #     end)
  #     |> Enum.map(fn {x, y, h} ->
  #       case take_step(map, {x, y}, h) do
  #         {:ok, {nx, ny, _}} -> {nx, ny}
  #         _ -> nil
  #       end
  #     end)
  #     |> Enum.reject(&is_nil/1)
  #
  #   {lx, ly, _} =
  #     List.first(state.path)
  #
  #   potential_loop_obsticle_locations =
  #     [{lx, ly} | potential_loop_obsticle_locations]
  #
  #   {map, guard, state, potential_loop_obsticle_locations}
  # end

  # Brute force solutions that checks every possible location in the path
  defp find_potential_loop_locations({map, guard, state}) do
    potential_loop_obsticle_locations =
      state.path
      |> Enum.map(fn {x, y, _} ->
        {x, y}
      end)
      |> Enum.uniq()

    {map, guard, state, potential_loop_obsticle_locations}
  end

  defp select_loops({map, _guard, initial_state, potential_loop_obsticle_locations}) do
    IO.puts("Found #{length(potential_loop_obsticle_locations)} potential loop locations")

    potential_loop_obsticle_locations
    |> Task.async_stream(
      fn {x, y} ->
        {_loop_map, _loop_guard, state} =
          simulate_patrol({mark_map(map, {x, y}, :obstacle), initial_state.initial_guard})

        if state.loop do
          IO.puts("Found loop with obstacle at (#{x}, #{y})")

          # state.patrol_map
          # |> mark_map({x, y}, :mark)
          # |> print_map(state.initial_guard)

          {x, y, state.path}
        else
          nil
        end
      end,
      timeout: :infinity
    )
    |> Stream.filter(&match?({:ok, value} when not is_nil(value), &1))
    |> Stream.map(fn {:ok, value} -> value end)
    |> Enum.to_list()
    |> Enum.uniq_by(fn {_, _, path} -> path end)
  end

  defp count_visited_tiles({_, _, %{patrol_map: patrol_map}}) do
    patrol_map
    |> Enum.flat_map(&Enum.filter(&1, fn {_, _, tile} -> tile == :visited end))
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
      |> Map.put(:patrol_map, mark_map(state.patrol_map, {guard_x, guard_y}, :visited))

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

  defp print_map(map, {gx, gy, _gh}) do
    grid =
      Enum.map(map, fn row ->
        Enum.map(row, fn {x, y, tile} ->
          cond do
            gx == x and gy == y -> "G"
            tile == :guard -> "I"
            tile == :obstacle -> "#"
            tile == :empty -> "."
            tile == :visited -> "X"
            tile == :mark -> "O"
            true -> "?"
          end
        end)
        |> Enum.join()
      end)
      |> Enum.join("\n")

    IO.puts("------------")
    IO.puts(grid)
  end
end
