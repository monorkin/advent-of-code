defmodule AdventOfCode.Day16 do
  import AdventOfCode.Utils

  # It's time again for the Reindeer Olympics! This year, the big event is the Reindeer Maze, where the Reindeer compete for the lowest score.
  #
  # You and The Historians arrive to search for the Chief right as the event is about to start. It wouldn't hurt to watch a little, right?
  #
  # The Reindeer start on the Start Tile (marked S) facing East and need to reach the End Tile (marked E). They can move forward one tile at a time (increasing their score by 1 point), but never into a wall (#). They can also rotate clockwise or counterclockwise 90 degrees at a time (increasing their score by 1000 points).
  #
  # To figure out the best place to sit, you start by grabbing a map (your puzzle input) from a nearby kiosk. For example:
  #
  # ###############
  # #.......#....E#
  # #.#.###.#.###.#
  # #.....#.#...#.#
  # #.###.#####.#.#
  # #.#.#.......#.#
  # #.#.#####.###.#
  # #...........#.#
  # ###.#.#####.#.#
  # #...#.....#.#.#
  # #.#.#.###.#.#.#
  # #.....#...#.#.#
  # #.###.#.#.#.#.#
  # #S..#.....#...#
  # ###############
  #
  # There are many paths through this maze, but taking any of the best paths would incur a score of only 7036. This can be achieved by taking a total of 36 steps forward and turning 90 degrees a total of 7 times:
  #
  #
  # ###############
  # #.......#....E#
  # #.#.###.#.###^#
  # #.....#.#...#^#
  # #.###.#####.#^#
  # #.#.#.......#^#
  # #.#.#####.###^#
  # #..>>>>>>>>v#^#
  # ###^#.#####v#^#
  # #>>^#.....#v#^#
  # #^#.#.###.#v#^#
  # #^....#...#v#^#
  # #^###.#.#.#v#^#
  # #S..#.....#>>^#
  # ###############
  #
  # Here's a second example:
  #
  # #################
  # #...#...#...#..E#
  # #.#.#.#.#.#.#.#.#
  # #.#.#.#...#...#.#
  # #.#.#.#.###.#.#.#
  # #...#.#.#.....#.#
  # #.#.#.#.#.#####.#
  # #.#...#.#.#.....#
  # #.#.#####.#.###.#
  # #.#.#.......#...#
  # #.#.###.#####.###
  # #.#.#...#.....#.#
  # #.#.#.#####.###.#
  # #.#.#.........#.#
  # #.#.#.#########.#
  # #S#.............#
  # #################
  #
  # In this maze, the best paths cost 11048 points; following one such path would look like this:
  #
  # #################
  # #...#...#...#..E#
  # #.#.#.#.#.#.#.#^#
  # #.#.#.#...#...#^#
  # #.#.#.#.###.#.#^#
  # #>>v#.#.#.....#^#
  # #^#v#.#.#.#####^#
  # #^#v..#.#.#>>>>^#
  # #^#v#####.#^###.#
  # #^#v#..>>>>^#...#
  # #^#v###^#####.###
  # #^#v#>>^#.....#.#
  # #^#v#^#####.###.#
  # #^#v#^........#.#
  # #^#v#^#########.#
  # #S#>>^..........#
  # #################
  #
  # Note that the path shown above includes one 90 degree turn as the very first move, rotating the Reindeer from facing East to facing North.
  #
  # Analyze your map carefully. What is the lowest score a Reindeer could possibly get?
  #
  # Your puzzle answer was 109516.

  def find_best_scoring_path(input) do
    input
    |> parse_grid()
    |> init()
    |> a_star()
    |> best_score()
  end

  # --- Part Two ---
  #
  # Now that you know what the best paths look like, you can figure out the best spot to sit.
  #
  # Every non-wall tile (S, ., or E) is equipped with places to sit along the edges of the tile. While determining which of these tiles would be the best spot to sit depends on a whole bunch of factors (how comfortable the seats are, how far away the bathrooms are, whether there's a pillar blocking your view, etc.), the most important factor is whether the tile is on one of the best paths through the maze. If you sit somewhere else, you'd miss all the action!
  #
  # So, you'll need to determine which tiles are part of any best path through the maze, including the S and E tiles.
  #
  # In the first example, there are 45 tiles (marked O) that are part of at least one of the various best paths through the maze:
  #
  # ###############
  # #.......#....O#
  # #.#.###.#.###O#
  # #.....#.#...#O#
  # #.###.#####.#O#
  # #.#.#.......#O#
  # #.#.#####.###O#
  # #..OOOOOOOOO#O#
  # ###O#O#####O#O#
  # #OOO#O....#O#O#
  # #O#O#O###.#O#O#
  # #OOOOO#...#O#O#
  # #O###.#.#.#O#O#
  # #O..#.....#OOO#
  # ###############
  #
  # In the second example, there are 64 tiles that are part of at least one of the best paths:
  #
  # #################
  # #...#...#...#..O#
  # #.#.#.#.#.#.#.#O#
  # #.#.#.#...#...#O#
  # #.#.#.#.###.#.#O#
  # #OOO#.#.#.....#O#
  # #O#O#.#.#.#####O#
  # #O#O..#.#.#OOOOO#
  # #O#O#####.#O###O#
  # #O#O#..OOOOO#OOO#
  # #O#O###O#####O###
  # #O#O#OOO#..OOO#.#
  # #O#O#O#####O###.#
  # #O#O#OOOOOOO..#.#
  # #O#O#O#########.#
  # #O#OOO..........#
  # #################
  #
  # Analyze your map further. How many tiles are part of at least one of the best paths through the maze?
  #
  # Your puzzle answer was 568.

  def number_of_tiles_along_the_best_paths(input) do
    input
    |> parse_grid()
    |> init()
    |> djikstra()
    |> count_tiles_along_best_paths()
  end

  defp count_tiles_along_best_paths(state) do
    state.paths
    |> List.flatten()
    |> Enum.uniq()
    |> length()
  end

  defp djikstra(state), do: search(:djikstra, state)

  defp a_star(state), do: search(:a_star, state)

  defp search(algorithm, state) do
    initial_state = %{
      position: state.start,
      direction: state.initial_direction,
      cost: 0,
      path: [state.start]
    }

    initial_cost =
      if algorithm == :djikstra, do: 0, else: manhattan_distance(state.start, state.finish)

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
              :djikstra ->
                Enum.reduce(neighbors, rest, fn neighbor, acc ->
                  :gb_sets.add({neighbor.cost, neighbor}, acc)
                end)

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
      {:east, {1, 0}},
      {:north, {0, -1}},
      {:west, {-1, 0}},
      {:south, {0, 1}}
    ]

    Enum.flat_map(possible_moves, fn {new_direction, {dx, dy}} ->
      {x, y} = state.position
      new_pos = {x + dx, y + dy}

      case Map.get(grid, new_pos) do
        :wall ->
          []

        _ ->
          turn_cost = turn_score(state.direction, new_direction)
          move_cost = 1
          total_cost = state.cost + turn_cost + move_cost

          [
            %{
              position: new_pos,
              direction: new_direction,
              cost: total_cost,
              path: state.path ++ [new_pos]
            }
          ]
      end
    end)
  end

  defp visited?(state, closed_set) do
    case Map.get(closed_set, {state.position, state.direction}) do
      nil -> false
      best_cost -> state.cost > best_cost
    end
  end

  defp mark_visited(state, closed_set) do
    case Map.get(closed_set, {state.position, state.direction}) do
      nil ->
        Map.put(closed_set, {state.position, state.direction}, state.cost)

      existing_cost when state.cost <= existing_cost ->
        Map.put(closed_set, {state.position, state.direction}, state.cost)

      _ ->
        closed_set
    end
  end

  defp manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  defp best_score(state) do
    state.best_score
  end

  defp opposite_direction(direction) do
    case direction do
      :east -> :west
      :north -> :south
      :west -> :east
      :south -> :north
    end
  end

  defp turn_score(from, to) do
    opposite_direction = opposite_direction(from)

    case to do
      ^from -> 0
      ^opposite_direction -> 1000 * 2
      _ -> 1000
    end
  end

  defp init(map) do
    start = Enum.find(map, fn {_, tile} -> tile == "S" end) |> elem(0)
    if is_nil(start), do: raise("No start found")

    finish = Enum.find(map, fn {_, tile} -> tile == "E" end) |> elem(0)
    if is_nil(finish), do: raise("No finish found")

    map =
      map
      |> Enum.map(fn {position, tile} ->
        case tile do
          "#" -> {position, :wall}
          _ -> nil
        end
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.into(%{})

    %{
      map: map,
      scores: %{},
      start: start,
      finish: finish,
      initial_direction: :east,
      paths: [],
      best_score: nil
    }
  end

  defp draw_path(state, path) do
    coords = state.map |> Enum.map(&elem(&1, 0))
    width = coords |> Enum.map(&elem(&1, 0)) |> Enum.max()
    height = coords |> Enum.map(&elem(&1, 1)) |> Enum.max()

    for y <- 0..height do
      for x <- 0..width do
        coord = {x, y}
        tile = Map.get(state.map, coord)

        cond do
          coord == state.start ->
            IO.write("S")

          coord == state.finish ->
            IO.write("E")

          tile == :wall ->
            IO.write("#")

          coord in path ->
            IO.write(IO.ANSI.red() <> "o" <> IO.ANSI.reset())

          true ->
            IO.write(" ")
        end
      end

      IO.puts("")
    end
  end
end
