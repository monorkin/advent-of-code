defmodule AdventOfCode.Day18 do
  import AdventOfCode.Utils

  def shortest_path(input, size, simulation_steps) do
    input
    |> parse(size)
    |> simulate(simulation_steps)
    |> find_shortest_path()
  end

  defp find_shortest_path(state) do
    state
    |> inspect_state()
    |> a_star()
    |> inspect_state()
    |> Map.get(:best_score)
  end

  defp simulate(state, steps) do
    IO.puts("Simulationg...")

    0..max(steps - 1, 0)
    |> Enum.reduce(state, fn i, state ->
      input = state.inputs |> Enum.at(i, nil)
      if is_nil(input), do: raise("No input found for step #{i}")

      map = Map.put(state.map, input, :corrup)
      Map.put(state, :map, map)
    end)
  end

  defp parse(input, {width, height}) do
    IO.puts("Parsing...")

    inputs =
      input
      |> break_into_rows()
      |> Enum.map(fn row ->
        [x, y] =
          row
          |> String.split(",", trim: true)
          |> Enum.map(&String.to_integer/1)

        {x, y}
      end)

    %{
      map: %{},
      start: {0, 0},
      finish: {width, height},
      width: width,
      height: height,
      inputs: inputs,
      paths: [],
      best_score: nil
    }
  end

  defp a_star(state), do: search(:a_star, state)

  defp search(algorithm, state) do
    IO.puts("Searching...")

    initial_state = %{
      position: state.start,
      cost: 0,
      path: [state.start],
      width: state.width,
      height: state.height
    }

    initial_cost = manhattan_distance(state.start, state.finish)

    open_set = :gb_sets.singleton({initial_cost, initial_state})
    # Changed from MapSet.new()
    closed_set = %{}
    best_paths = []
    best_cost = nil

    {best_score, paths} =
      search(algorithm, open_set, closed_set, state.map, state.finish, best_paths, best_cost)

    state
    |> Map.put(:paths, paths)
    |> Map.put(:best_score, best_score)
  end

  defp search(algorithm, open_set, closed_set, grid, finish, best_paths, best_cost) do
    if :gb_sets.is_empty(open_set) do
      {best_cost, best_paths}
    else
      {{_, current_state}, rest} = :gb_sets.take_smallest(open_set)
      current_cost = current_state.cost
      inspect_map(grid, current_state.width, current_state.height, open_set, closed_set)

      cond do
        current_state.position == finish ->
          # Found a path to finish
          case best_cost do
            nil ->
              # First solution found
              search(
                algorithm,
                rest,
                closed_set,
                grid,
                finish,
                [current_state.path],
                current_state.cost
              )

            ^current_cost ->
              # Another solution with same cost
              search(
                algorithm,
                rest,
                closed_set,
                grid,
                finish,
                [current_state.path | best_paths],
                best_cost
              )

            cost when current_state.cost < cost ->
              # Better solution found
              search(
                algorithm,
                rest,
                closed_set,
                grid,
                finish,
                [current_state.path],
                current_state.cost
              )

            cost when current_state.cost > cost ->
              # Worse solution, ignore this path but continue searching
              search(
                algorithm,
                rest,
                closed_set,
                grid,
                finish,
                best_paths,
                best_cost
              )
          end

        visited?(current_state, closed_set) ->
          search(algorithm, rest, closed_set, grid, finish, best_paths, best_cost)

        true ->
          neighbors = get_neighbors(current_state, grid)
          new_closed_set = mark_visited(current_state, closed_set)

          new_open_set =
            case algorithm do
              :a_star ->
                Enum.reduce(neighbors, rest, fn neighbor, acc ->
                  f_score = neighbor.cost + manhattan_distance(neighbor.position, finish)
                  :gb_sets.add({f_score, neighbor}, acc)
                end)
            end

          search(algorithm, new_open_set, new_closed_set, grid, finish, best_paths, best_cost)
      end
    end
  end

  defp get_neighbors(state, grid) do
    possible_moves = [
      {1, 0},
      {0, -1},
      {-1, 0},
      {0, 1}
    ]

    Enum.flat_map(possible_moves, fn {dx, dy} ->
      {x, y} = state.position
      new_pos = {x + dx, y + dy}
      new_tile = Map.get(grid, new_pos)

      cond do
        elem(new_pos, 0) < 0 or elem(new_pos, 0) > state.width ->
          []

        elem(new_pos, 1) < 0 or elem(new_pos, 1) > state.height ->
          []

        is_nil(new_tile) ->
          move_cost = 1
          total_cost = state.cost + move_cost

          [
            %{
              position: new_pos,
              cost: total_cost,
              path: state.path ++ [new_pos],
              width: state.width,
              height: state.height
            }
          ]

        true ->
          []
      end
    end)
  end

  defp visited?(state, closed_set) do
    case Map.get(closed_set, state.position) do
      nil -> false
      best_cost -> state.cost > best_cost
    end
  end

  defp mark_visited(state, closed_set) do
    case Map.get(closed_set, state.position) do
      nil ->
        Map.put(closed_set, state.position, state.cost)

      existing_cost when state.cost <= existing_cost ->
        Map.put(closed_set, state.position, state.cost)

      _ ->
        closed_set
    end
  end

  defp manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  defp inspect_state(state) do
    IO.puts("Best score: #{state.best_score}")
    IO.puts("Paths: #{Enum.count(state.paths)}")

    all_paths =
      state
      |> Map.get(:paths)
      |> List.flatten()
      |> Enum.uniq()

    for y <- 0..state.height do
      for x <- 0..state.width do
        cell = Map.get(state.map, {x, y})

        tile =
          cond do
            {x, y} in all_paths -> IO.ANSI.green() <> "O" <> IO.ANSI.reset()
            cell == :corrup -> IO.ANSI.red() <> "#" <> IO.ANSI.reset()
            true -> "."
          end

        IO.write(tile)
      end

      IO.puts("")
    end

    state
  end

  defp inspect_map(grid, width, height, _open_set, closed_set) do
    IO.puts("Inspecting map...\n\n")

    for y <- 0..height do
      for x <- 0..width do
        coord = {x, y}
        cell = Map.get(grid, coord)
        closed = Map.get(closed_set, coord, false)

        tile =
          cond do
            closed ->
              IO.ANSI.yellow() <> "X" <> IO.ANSI.reset()

            cell == :corrup ->
              IO.ANSI.red() <> "#" <> IO.ANSI.reset()

            true ->
              "."
          end

        IO.write(tile)
      end

      IO.puts("")
    end
  end
end
