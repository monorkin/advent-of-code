defmodule AdventOfCode.Day14 do
  import AdventOfCode.Utils

  @robot_regex ~r/p=(\d+),(\d+) v=(-?\d+),(-?\d+)/

  # --- Day 14: Restroom Redoubt ---
  #
  # One of The Historians needs to use the bathroom; fortunately, you know there's a bathroom near an unvisited location on their list, and so you're all quickly teleported directly to the lobby of Easter Bunny Headquarters.
  #
  # Unfortunately, EBHQ seems to have "improved" bathroom security again after your last visit. The area outside the bathroom is swarming with robots!
  #
  # To get The Historian safely to the bathroom, you'll need a way to predict where the robots will be in the future. Fortunately, they all seem to be moving on the tile floor in predictable straight lines.
  #
  # You make a list (your puzzle input) of all of the robots' current positions (p) and velocities (v), one robot per line. For example:
  #
  # p=0,4 v=3,-3
  # p=6,3 v=-1,-3
  # p=10,3 v=-1,2
  # p=2,0 v=2,-1
  # p=0,0 v=1,3
  # p=3,0 v=-2,-2
  # p=7,6 v=-1,-3
  # p=3,0 v=-1,-2
  # p=9,3 v=2,3
  # p=7,3 v=-1,2
  # p=2,4 v=2,-3
  # p=9,5 v=-3,-3
  #
  # Each robot's position is given as p=x,y where x represents the number of tiles the robot is from the left wall and y represents the number of tiles from the top wall (when viewed from above). So, a position of p=0,0 means the robot is all the way in the top-left corner.
  #
  # Each robot's velocity is given as v=x,y where x and y are given in tiles per second. Positive x means the robot is moving to the right, and positive y means the robot is moving down. So, a velocity of v=1,-2 means that each second, the robot moves 1 tile to the right and 2 tiles up.
  #
  # The robots outside the actual bathroom are in a space which is 101 tiles wide and 103 tiles tall (when viewed from above). However, in this example, the robots are in a space which is only 11 tiles wide and 7 tiles tall.
  #
  # The robots are good at navigating over/under each other (due to a combination of springs, extendable legs, and quadcopters), so they can share the same tile and don't interact with each other. Visually, the number of robots on each tile in this example looks like this:
  #
  # 1.12.......
  # ...........
  # ...........
  # ......11.11
  # 1.1........
  # .........1.
  # .......1...
  #
  # These robots have a unique feature for maximum bathroom security: they can teleport. When a robot would run into an edge of the space they're in, they instead teleport to the other side, effectively wrapping around the edges. Here is what robot p=2,4 v=2,-3 does for the first few seconds:
  #
  # Initial state:
  # ...........
  # ...........
  # ...........
  # ...........
  # ..1........
  # ...........
  # ...........
  #
  # After 1 second:
  # ...........
  # ....1......
  # ...........
  # ...........
  # ...........
  # ...........
  # ...........
  #
  # After 2 seconds:
  # ...........
  # ...........
  # ...........
  # ...........
  # ...........
  # ......1....
  # ...........
  #
  # After 3 seconds:
  # ...........
  # ...........
  # ........1..
  # ...........
  # ...........
  # ...........
  # ...........
  #
  # After 4 seconds:
  # ...........
  # ...........
  # ...........
  # ...........
  # ...........
  # ...........
  # ..........1
  #
  # After 5 seconds:
  # ...........
  # ...........
  # ...........
  # .1.........
  # ...........
  # ...........
  # ...........
  #
  # The Historian can't wait much longer, so you don't have to simulate the robots for very long. Where will the robots be after 100 seconds?
  #
  # In the above example, the number of robots on each tile after 100 seconds has elapsed looks like this:
  #
  # ......2..1.
  # ...........
  # 1..........
  # .11........
  # .....1.....
  # ...12......
  # .1....1....
  #
  # To determine the safest area, count the number of robots in each quadrant after 100 seconds. Robots that are exactly in the middle (horizontally or vertically) don't count as being in any quadrant, so the only relevant robots are:
  #
  # ..... 2..1.
  # ..... .....
  # 1.... .....
  #
  # ..... .....
  # ...12 .....
  # .1... 1....
  #
  # In this example, the quadrants contain 1, 3, 4, and 1 robot. Multiplying these together gives a total safety factor of 12.
  #
  # Predict the motion of the robots in your list within a space which is 101 tiles wide and 103 tiles tall. What will the safety factor be after exactly 100 seconds have elapsed?
  #
  # Your puzzle answer was 229839456.
  # --- Part Two ---
  #
  # During the bathroom break, someone notices that these robots seem awfully similar to ones built and used at the North Pole. If they're the same type of robots, they should have a hard-coded Easter egg: very rarely, most of the robots should arrange themselves into a picture of a Christmas tree.
  #
  # What is the fewest number of seconds that must elapse for the robots to display the Easter egg?
  #
  # Your puzzle answer was 7138.

  def calculate_safety_factor_after(input, {_, _} = size, seconds) do
    input
    |> break_into_rows()
    |> parse()
    |> init()
    |> simulate(size, seconds)
    |> inspect_robots(size)
    |> calculate_safety_factor(size)
  end

  defp calculate_safety_factor(state, size) do
    state
    |> count_quadrants(size)
    |> Enum.reduce(1, fn
      {nil, _}, acc -> acc
      {_, count}, acc -> acc * count
    end)
  end

  defp count_quadrants(state, size) do
    state.robots
    |> Enum.group_by(&quadrant(&1.position, size))
    |> Enum.map(fn {quadrant, robots} -> {quadrant, length(robots)} end)
  end

  defp quadrant({x, y}, {max_x, max_y}) do
    if rem(max_x, 2) != 1, do: raise("Board must have an odd size but its width is #{max_x}")
    if rem(max_y, 2) != 1, do: raise("Board must have an odd size but its height is #{max_y}")

    mid_x = floor(max_x / 2)
    mid_y = floor(max_y / 2)

    cond do
      x >= 0 and x < mid_x and y >= 0 and y < mid_y ->
        :q1

      x > mid_x and x <= max_x and y >= 0 and y < mid_y ->
        :q2

      x >= 0 and x < mid_x and y > mid_y and y <= max_y ->
        :q3

      x > mid_x and x <= max_x and y > mid_y and y <= max_y ->
        :q4

      true ->
        nil
    end
  end

  defp simulate(state, size, seconds) do
    robots =
      state.robots
      |> Enum.map(&move_robot(&1, size, seconds))

    Map.put(state, :robots, robots)
  end

  defp move_robot(robot, {max_x, max_y}, seconds) do
    {x, y} = robot.position
    {vx, vy} = robot.velocity

    nx = rem(x + 1 + vx * seconds, max_x)
    nx = if nx == 0, do: max_x, else: nx - 1
    nx = if nx < 0, do: nx + max_x, else: nx

    ny = rem(y + 1 + vy * seconds, max_y)
    ny = if ny == 0, do: max_y, else: ny - 1
    ny = if ny < 0, do: ny + max_y, else: ny

    Map.put(robot, :position, {nx, ny})
  end

  defp init(robots) do
    %{robots: robots}
  end

  defp parse(rows) do
    rows
    |> Enum.reduce({[], 0}, fn row, {robots, next_id} ->
      [[_, x, y, vx, vy]] = Regex.scan(@robot_regex, row)

      robot = %{
        id: next_id,
        position: {String.to_integer(x), String.to_integer(y)},
        velocity: {String.to_integer(vx), String.to_integer(vy)}
      }

      {[robot | robots], next_id + 1}
    end)
    |> elem(0)
  end

  defp inspect_robots(state, {max_y, max_x}) do
    mid_x = floor(max_x / 2)
    mid_y = floor(max_y / 2)

    for y <- 0..max_y do
      for x <- 0..max_x do
        robot = Enum.find(state.robots, fn robot -> robot.position == {x, y} end)

        background =
          if y == mid_y or x == mid_x do
            IO.ANSI.red_background()
          else
            ""
          end

        id =
          cond do
            is_nil(robot) ->
              "."

            robot.id < 10 ->
              "#{robot.id}"

            true ->
              IO.ANSI.green() <> "#{rem(robot.id, 10)}" <> IO.ANSI.reset()
          end

        IO.write(background <> id <> IO.ANSI.reset())
      end

      IO.puts("")
    end

    state
  end
end
