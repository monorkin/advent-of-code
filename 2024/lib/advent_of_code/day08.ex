defmodule AdventOfCode.Day08 do
  import AdventOfCode.Utils

  # --- Day 8: Resonant Collinearity ---
  #
  # You find yourselves on the roof of a top-secret Easter Bunny installation.
  #
  # While The Historians do their thing, you take a look at the familiar huge antenna. Much to your surprise, it seems to have been reconfigured to emit a signal that makes people 0.1% more likely to buy Easter Bunny brand Imitation Mediocre Chocolate as a Christmas gift! Unthinkable!
  #
  # Scanning across the city, you find that there are actually many such antennas. Each antenna is tuned to a specific frequency indicated by a single lowercase letter, uppercase letter, or digit. You create a map (your puzzle input) of these antennas. For example:
  #
  # ............
  # ........0...
  # .....0......
  # .......0....
  # ....0.......
  # ......A.....
  # ............
  # ............
  # ........A...
  # .........A..
  # ............
  # ............
  #
  # The signal only applies its nefarious effect at specific antinodes based on the resonant frequencies of the antennas. In particular, an antinode occurs at any point that is perfectly in line with two antennas of the same frequency - but only when one of the antennas is twice as far away as the other. This means that for any pair of antennas with the same frequency, there are two antinodes, one on either side of them.
  #
  # So, for these two antennas with frequency a, they create the two antinodes marked with #:
  #
  # ..........
  # ...#......
  # ..........
  # ....a.....
  # ..........
  # .....a....
  # ..........
  # ......#...
  # ..........
  # ..........
  #
  # Adding a third antenna with the same frequency creates several more antinodes. It would ideally add four antinodes, but two are off the right side of the map, so instead it adds only two:
  #
  # ..........
  # ...#......
  # #.........
  # ....a.....
  # ........a.
  # .....a....
  # ..#.......
  # ......#...
  # ..........
  # ..........
  #
  # Antennas with different frequencies don't create antinodes; A and a count as different frequencies. However, antinodes can occur at locations that contain antennas. In this diagram, the lone antenna with frequency capital A creates no antinodes but has a lowercase-a-frequency antinode at its location:
  #
  # ..........
  # ...#......
  # #.........
  # ....a.....
  # ........a.
  # .....a....
  # ..#.......
  # ......A...
  # ..........
  # ..........
  #
  # The first example has antennas with two different frequencies, so the antinodes they create look like this, plus an antinode overlapping the topmost A-frequency antenna:
  #
  # ......#....#
  # ...#....0...
  # ....#0....#.
  # ..#....0....
  # ....0....#..
  # .#....A.....
  # ...#........
  # #......#....
  # ........A...
  # .........A..
  # ..........#.
  # ..........#.
  #
  # Because the topmost A-frequency antenna overlaps with a 0-frequency antinode, there are 14 total unique locations that contain an antinode within the bounds of the map.
  #
  # Calculate the impact of the signal. How many unique locations within the bounds of the map contain an antinode?
  #
  # Your puzzle answer was 376.

  def antinodes_count_without_harmonics(input) do
    input
    |> break_into_rows()
    |> parse_map()
    |> find_antinodes(1)
    |> count_antinodes()
  end

  # --- Part Two ---
  #
  # Watching over your shoulder as you work, one of The Historians asks if you took the effects of resonant harmonics into your calculations.
  #
  # Whoops!
  #
  # After updating your model, it turns out that an antinode occurs at any grid position exactly in line with at least two antennas of the same frequency, regardless of distance. This means that some of the new antinodes will occur at the position of each antenna (unless that antenna is the only one of its frequency).
  #
  # So, these three T-frequency antennas now create many antinodes:
  #
  # T....#....
  # ...T......
  # .T....#...
  # .........#
  # ..#.......
  # ..........
  # ...#......
  # ..........
  # ....#.....
  # ..........
  #
  # In fact, the three T-frequency antennas are all exactly in line with two antennas, so they are all also antinodes! This brings the total number of antinodes in the above example to 9.
  #
  # The original example now has 34 antinodes, including the antinodes that appear on every antenna:
  #
  # ##....#....#
  # .#.#....0...
  # ..#.#0....#.
  # ..##...0....
  # ....0....#..
  # .#...#A....#
  # ...#..#.....
  # #....#.#....
  # ..#.....A...
  # ....#....A..
  # .#........#.
  # ...#......##
  #
  # Calculate the impact of the signal using this updated model. How many unique locations within the bounds of the map contain an antinode?
  #
  # Your puzzle answer was 1352.

  def antinodes_count_with_harmonics(input) do
    input
    |> break_into_rows()
    |> parse_map()
    |> find_antinodes(:infinity)
    |> count_antinodes_and_antennas()
  end

  defp count_antinodes_and_antennas({_, _, _, meta}) do
    antennas =
      meta.antennas
      |> Enum.flat_map(fn {_, locations} -> locations end)

    antinodes =
      meta.antinodes
      |> Enum.flat_map(fn {_, locations} -> locations end)

    (antennas ++ antinodes)
    |> Enum.uniq()
    |> Enum.count()
  end

  defp count_antinodes({_, _, _, meta}) do
    meta.antinodes
    |> Enum.flat_map(fn {_, locations} -> locations end)
    |> Enum.uniq()
    |> Enum.count()
  end

  defp find_antinodes({width, height, nodes, meta}, occurances) do
    {new_nodes, new_meta} =
      Enum.reduce(
        meta.antennas,
        {nodes, meta},
        fn {type, antenna_nodes}, {nodes, meta} ->
          antenna_nodes
          |> Combination.combine(2)
          |> Enum.reduce({nodes, meta}, fn [a, b], {nodes, meta} ->
            antinode_locations =
              find_antinode_locations(a, b, width, height, occurances)

            new_nodes =
              Enum.reduce(antinode_locations, nodes, fn location, nodes ->
                tag_node(nodes, location, {:antinode, type})
              end)

            new_meta =
              Map.update(meta, :antinodes, %{}, fn antinodes ->
                Map.update(antinodes, type, antinode_locations, fn locations ->
                  Enum.uniq(locations ++ antinode_locations)
                end)
              end)

            {new_nodes, new_meta}
          end)
        end
      )

    {width, height, new_nodes, new_meta}
  end

  defp tag_node(nodes, location, tag) do
    if Map.has_key?(nodes, location) do
      Map.update(nodes, location, [], fn tags -> Enum.uniq([tag | tags]) end)
    else
      Map.put_new(nodes, location, [tag])
    end
  end

  # The wording on this is very confusing, but esentially an antinode occurs
  # behind each antenna pair exactly their distance away from them.
  # So if you have 2 antennas 3 fields apart, the antinodes will be 3 fields
  # behind each antenna.
  defp find_antinode_locations({ax, ay} = p1, {bx, by} = p2, width, height, occurances) do
    v1 = {ax - bx, ay - by}
    v2 = {bx - ax, by - ay}

    antinodes =
      extend_point_by_vector_multiple_times(p1, v1, width, height, occurances) ++
        extend_point_by_vector_multiple_times(p2, v2, width, height, occurances)

    antinodes
    |> Enum.uniq()
    |> Enum.filter(fn point -> point != {ax, ay} and point != {bx, by} end)
  end

  defp extend_point_by_vector_multiple_times(
         point,
         vector,
         width,
         height,
         occurances,
         i \\ 1,
         acc \\ []
       )

  defp extend_point_by_vector_multiple_times(
         point,
         {vx, vy} = vector,
         width,
         height,
         :infinity,
         i,
         acc
       ) do
    new_point = extend_point_by_vector(point, {vx * i, vy * i})

    if in_bounds(new_point, width, height) do
      extend_point_by_vector_multiple_times(point, vector, width, height, :infinity, i + 1, [
        new_point | acc
      ])
    else
      acc
    end
  end

  defp extend_point_by_vector_multiple_times(
         point,
         {vx, vy} = vector,
         width,
         height,
         occurances,
         i,
         acc
       ) do
    if i > occurances do
      acc
    else
      new_point = extend_point_by_vector(point, {vx, vy})

      if in_bounds(new_point, width, height) do
        extend_point_by_vector_multiple_times(
          new_point,
          vector,
          width,
          height,
          occurances,
          i + 1,
          [
            new_point | acc
          ]
        )
      else
        acc
      end
    end
  end

  defp extend_point_by_vector({x, y}, {vx, vy}) do
    {x + vx, y + vy}
  end

  defp in_bounds({x, y}, width, height) do
    x >= 0 and x < width and y >= 0 and y < height
  end

  defp parse_map(rows) do
    width = rows |> hd() |> String.length()
    height = rows |> length()

    nodes =
      rows
      |> Enum.map(&String.graphemes(&1))
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        row
        |> Enum.with_index()
        |> Enum.map(fn {cell, x} ->
          tile_type = parse_tile_type(cell)

          if tile_type == :space do
            nil
          else
            {{x, y}, [tile_type]}
          end
        end)
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.group_by(fn {location, _} -> location end)
      |> Enum.map(fn {location, nodes} -> {location, Enum.flat_map(nodes, &elem(&1, 1))} end)
      |> Enum.into(%{})

    antennas =
      nodes
      |> Enum.group_by(fn {_, [{:antenna, type}]} -> type end)
      |> Enum.map(fn {type, nodes} -> {type, Enum.map(nodes, &elem(&1, 0))} end)
      |> Enum.into(%{})

    meta = %{antennas: antennas, antinodes: %{}}

    {width, height, nodes, meta}
  end

  defp parse_tile_type(cell) do
    case cell do
      "." -> :space
      antenna -> {:antenna, antenna}
    end
  end

  # Prints a map and all it's info
  # Antennas are marked as green letters, antinodes as red letter
  # if an antinode is behind an antenna then it's printed as a green 
  # letter on a red background
  #
  # defp inspect_map({width, height, nodes, meta}) do
  #   IO.inspect(width, label: "WIDTH")
  #   IO.inspect(height, label: "HEIGHT")
  #   IO.inspect(nodes, label: "NODES")
  #   IO.inspect(meta, label: "META")
  #
  #   IO.puts("MAP:")
  #
  #   for y <- 0..(height - 1) do
  #     for x <- 0..(width - 1) do
  #       location = {x, y}
  #       node = Map.get(nodes, location)
  #
  #       if node do
  #         antenna =
  #           node
  #           |> Enum.find(fn
  #             {:antenna, _} -> true
  #             _ -> false
  #           end)
  #
  #         antinode =
  #           node
  #           |> Enum.find(fn
  #             {:antinode, _} -> true
  #             _ -> false
  #           end)
  #
  #         cond do
  #           antenna && antinode ->
  #             IO.write(
  #               IO.ANSI.red_background() <> IO.ANSI.green() <> elem(antenna, 1) <> IO.ANSI.reset()
  #             )
  #
  #           antenna ->
  #             IO.write(IO.ANSI.green() <> elem(antenna, 1) <> IO.ANSI.reset())
  #
  #           antinode ->
  #             IO.write(IO.ANSI.red() <> elem(antinode, 1) <> IO.ANSI.reset())
  #         end
  #       else
  #         IO.write(".")
  #       end
  #     end
  #
  #     IO.puts("")
  #   end
  #
  #   {width, height, nodes, meta}
  # end
end
