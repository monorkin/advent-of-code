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
    |> djikstra()
    |> best_score()
  end

  def number_of_tiles_along_the_best_paths(input) do
    input
    |> parse_grid()
    |> init()
    |> djikstra()
    |> count_tiles_along_best_paths()
  end

  defp count_tiles_along_best_paths(state) do
    paths =
      state
      |> find_paths()
      |> score_paths(:east)

    Enum.each(paths, fn path ->
      draw_path(state, path)
      IO.puts("\n\n\n\n")
    end)
  end

  defp score_paths(paths, initial_facing) do
    paths
    |> Enum.map(fn path -> {path, score_path(path, initial_facing)} end)
  end

  defp score_path(path, initial_facing) do
    path
    |> Enum.reduce(
      {0, initial_facing, tl(path)},
      fn {x, y}, {score, facing, {px, py}} ->
        {dx, dy} = {x - px, y - py}

        going =
          case {dx, dy} do
            {1, 0} -> :east
            {0, -1} -> :north
            {-1, 0} -> :west
            {0, 1} -> :south
          end
      end
    )
  end

  defp find_paths(state, coords \\ nil, path \\ [])

  defp find_paths(state, nil, path) do
    find_paths(state, state.current_position |> elem(0), path)
  end

  defp find_paths(%{finish: finish}, coord, path) when finish == coord do
    [path]
  end

  defp find_paths(state, {x, y}, path) do
    cond do
      # Avoid loops
      {x, y} in path ->
        []

      # Avoid walls and unknown tiles - they aren't on any path
      Map.get(state.scores, {x, y}) == nil ->
        []

      true ->
        east_coord = {x + 1, y}
        north_coord = {x, y + 1}
        west_coord = {x - 1, y}
        south_coord = {x, y - 1}

        paths =
          [east_coord, north_coord, west_coord, south_coord]
          |> Enum.reduce([], fn coord, acc ->
            find_paths(state, coord, [{x, y} | path]) ++ acc
          end)

        if length(paths) == 0 do
          []
        else
          cheapest_path =
            Enum.min_by(paths, fn [head | _] -> Map.get(state.scores, head) end)

          min_price = Map.get(state.scores, hd(cheapest_path))

          paths
          |> Enum.filter(fn [head | _] -> Map.get(state.scores, head) == min_price end)
        end
    end
  end

  defp best_score(state) do
    Map.get(state.scores, state.finish)
  end

  defp djikstra(state) do
    state = djikstra(state, state.current_position, :east)
    state = djikstra(state, state.current_position, :north)
    state = djikstra(state, state.current_position, :west)
    djikstra(state, state.current_position, :south)
  end

  # Djikstra on a grid with a custom scoring function
  defp djikstra(state, {{x, y}, facing}, direction) do
    {dx, dy} =
      case direction do
        :east -> {1, 0}
        :north -> {0, 1}
        :west -> {-1, 0}
        :south -> {0, -1}
      end

    {nx, ny} = {x + dx, y + dy}
    next_tile = Map.get(state.map, {nx, ny})

    if next_tile == :wall do
      state
    else
      current_score = Map.get(state.scores, {x, y})

      opposite_direction =
        case direction do
          :east -> :west
          :north -> :south
          :west -> :east
          :south -> :north
        end

      move_score =
        case facing do
          # Continue in the same direction - costs 1 for the move
          ^direction -> 1
          # Go in the opposite direction - costs 2 * 1000 for 2 turns (cw or ccw) + 1 for the move
          ^opposite_direction -> 1000 * 2 + 1
          # Turn 90 degrees - costs 1 * 1000 for the turn (cw or ccw) + 1 for the move
          _ -> 1000 + 1
        end

      new_score = Map.get(state.scores, {nx, ny})

      if is_nil(new_score) or new_score >= current_score + move_score do
        scores = Map.put(state.scores, {nx, ny}, current_score + move_score)
        state = Map.put(state, :scores, scores)

        if state.finish == {nx, ny} do
          state
        else
          state = djikstra(state, {{nx, ny}, direction}, :east)
          state = djikstra(state, {{nx, ny}, direction}, :north)
          state = djikstra(state, {{nx, ny}, direction}, :west)
          djikstra(state, {{nx, ny}, direction}, :south)
        end
      else
        state
      end
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
      scores: %{start => 0},
      start: start,
      finish: finish,
      current_position: {start, :east}
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
