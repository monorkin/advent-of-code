defmodule AdventOfCode.Day15 do
  import AdventOfCode.Utils

  # --- Day 15: Warehouse Woes ---
  #
  # You appear back inside your own mini submarine! Each Historian drives their mini submarine in a different direction; maybe the Chief has his own submarine down here somewhere as well?
  #
  # You look up to see a vast school of lanternfish swimming past you. On closer inspection, they seem quite anxious, so you drive your mini submarine over to see if you can help.
  #
  # Because lanternfish populations grow rapidly, they need a lot of food, and that food needs to be stored somewhere. That's why these lanternfish have built elaborate warehouse complexes operated by robots!
  #
  # These lanternfish seem so anxious because they have lost control of the robot that operates one of their most important warehouses! It is currently running amok, pushing around boxes in the warehouse with no regard for lanternfish logistics or lanternfish inventory management strategies.
  #
  # Right now, none of the lanternfish are brave enough to swim up to an unpredictable robot so they could shut it off. However, if you could anticipate the robot's movements, maybe they could find a safe option.
  #
  # The lanternfish already have a map of the warehouse and a list of movements the robot will attempt to make (your puzzle input). The problem is that the movements will sometimes fail as boxes are shifted around, making the actual movements of the robot difficult to predict.
  #
  # For example:
  #
  # ##########
  # #..O..O.O#
  # #......O.#
  # #.OO..O.O#
  # #..O@..O.#
  # #O#..O...#
  # #O..O..O.#
  # #.OO.O.OO#
  # #....O...#
  # ##########
  #
  # <vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
  # vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
  # ><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
  # <<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
  # ^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
  # ^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
  # >^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
  # <><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
  # ^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
  # v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
  #
  # As the robot (@) attempts to move, if there are any boxes (O) in the way, the robot will also attempt to push those boxes. However, if this action would cause the robot or a box to move into a wall (#), nothing moves instead, including the robot. The initial positions of these are shown on the map at the top of the document the lanternfish gave you.
  #
  # The rest of the document describes the moves (^ for up, v for down, < for left, > for right) that the robot will attempt to make, in order. (The moves form a single giant sequence; they are broken into multiple lines just to make copy-pasting easier. Newlines within the move sequence should be ignored.)
  #
  # Here is a smaller example to get started:
  #
  # ########
  # #..O.O.#
  # ##@.O..#
  # #...O..#
  # #.#.O..#
  # #...O..#
  # #......#
  # ########
  #
  # <^^>>>vv<v>>v<<
  #
  # Were the robot to attempt the given sequence of moves, it would push around the boxes as follows:
  #
  # Initial state:
  # ########
  # #..O.O.#
  # ##@.O..#
  # #...O..#
  # #.#.O..#
  # #...O..#
  # #......#
  # ########
  #
  # Move <:
  # ########
  # #..O.O.#
  # ##@.O..#
  # #...O..#
  # #.#.O..#
  # #...O..#
  # #......#
  # ########
  #
  # Move ^:
  # ########
  # #.@O.O.#
  # ##..O..#
  # #...O..#
  # #.#.O..#
  # #...O..#
  # #......#
  # ########
  #
  # Move ^:
  # ########
  # #.@O.O.#
  # ##..O..#
  # #...O..#
  # #.#.O..#
  # #...O..#
  # #......#
  # ########
  #
  # Move >:
  # ########
  # #..@OO.#
  # ##..O..#
  # #...O..#
  # #.#.O..#
  # #...O..#
  # #......#
  # ########
  #
  # Move >:
  # ########
  # #...@OO#
  # ##..O..#
  # #...O..#
  # #.#.O..#
  # #...O..#
  # #......#
  # ########
  #
  # Move >:
  # ########
  # #...@OO#
  # ##..O..#
  # #...O..#
  # #.#.O..#
  # #...O..#
  # #......#
  # ########
  #
  # Move v:
  # ########
  # #....OO#
  # ##..@..#
  # #...O..#
  # #.#.O..#
  # #...O..#
  # #...O..#
  # ########
  #
  # Move v:
  # ########
  # #....OO#
  # ##..@..#
  # #...O..#
  # #.#.O..#
  # #...O..#
  # #...O..#
  # ########
  #
  # Move <:
  # ########
  # #....OO#
  # ##.@...#
  # #...O..#
  # #.#.O..#
  # #...O..#
  # #...O..#
  # ########
  #
  # Move v:
  # ########
  # #....OO#
  # ##.....#
  # #..@O..#
  # #.#.O..#
  # #...O..#
  # #...O..#
  # ########
  #
  # Move >:
  # ########
  # #....OO#
  # ##.....#
  # #...@O.#
  # #.#.O..#
  # #...O..#
  # #...O..#
  # ########
  #
  # Move >:
  # ########
  # #....OO#
  # ##.....#
  # #....@O#
  # #.#.O..#
  # #...O..#
  # #...O..#
  # ########
  #
  # Move v:
  # ########
  # #....OO#
  # ##.....#
  # #.....O#
  # #.#.O@.#
  # #...O..#
  # #...O..#
  # ########
  #
  # Move <:
  # ########
  # #....OO#
  # ##.....#
  # #.....O#
  # #.#O@..#
  # #...O..#
  # #...O..#
  # ########
  #
  # Move <:
  # ########
  # #....OO#
  # ##.....#
  # #.....O#
  # #.#O@..#
  # #...O..#
  # #...O..#
  # ########
  #
  # The larger example has many more moves; after the robot has finished those moves, the warehouse would look like this:
  #
  # ##########
  # #.O.O.OOO#
  # #........#
  # #OO......#
  # #OO@.....#
  # #O#.....O#
  # #O.....OO#
  # #O.....OO#
  # #OO....OO#
  # ##########
  #
  # The lanternfish use their own custom Goods Positioning System (GPS for short) to track the locations of the boxes. The GPS coordinate of a box is equal to 100 times its distance from the top edge of the map plus its distance from the left edge of the map. (This process does not stop at wall tiles; measure all the way to the edges of the map.)
  #
  # So, the box shown below has a distance of 1 from the top edge of the map and 4 from the left edge of the map, resulting in a GPS coordinate of 100 * 1 + 4 = 104.
  #
  # #######
  # #...O..
  # #......
  #
  # The lanternfish would like to know the sum of all boxes' GPS coordinates after the robot finishes moving. In the larger example, the sum of all boxes' GPS coordinates is 10092. In the smaller example, the sum is 2028.
  #
  # Predict the motion of the robot and boxes in the warehouse. After the robot is finished moving, what is the sum of all boxes' GPS coordinates?
  #
  # Your puzzle answer was 1509863.

  def sum_of_gps_coordinates(input) do
    input
    |> break_into_rows(true)
    |> parse()
    |> init()
    |> execute_moves()
    |> calculate_gps_coords()
    |> sum_gps_coords()
  end

  # --- Part Two ---
  #
  # The lanternfish use your information to find a safe moment to swim in and turn off the malfunctioning robot! Just as they start preparing a festival in your honor, reports start coming in that a second warehouse's robot is also malfunctioning.
  #
  # This warehouse's layout is surprisingly similar to the one you just helped. There is one key difference: everything except the robot is twice as wide! The robot's list of movements doesn't change.
  #
  # To get the wider warehouse's map, start with your original map and, for each tile, make the following changes:
  #
  #     If the tile is #, the new map contains ## instead.
  #     If the tile is O, the new map contains [] instead.
  #     If the tile is ., the new map contains .. instead.
  #     If the tile is @, the new map contains @. instead.
  #
  # This will produce a new warehouse map which is twice as wide and with wide boxes that are represented by []. (The robot does not change size.)
  #
  # The larger example from before would now look like this:
  #
  # ####################
  # ##....[]....[]..[]##
  # ##............[]..##
  # ##..[][]....[]..[]##
  # ##....[]@.....[]..##
  # ##[]##....[]......##
  # ##[]....[]....[]..##
  # ##..[][]..[]..[][]##
  # ##........[]......##
  # ####################
  #
  # Because boxes are now twice as wide but the robot is still the same size and speed, boxes can be aligned such that they directly push two other boxes at once. For example, consider this situation:
  #
  # #######
  # #...#.#
  # #.....#
  # #..OO@#
  # #..O..#
  # #.....#
  # #######
  #
  # <vv<<^^<<^^
  #
  # After appropriately resizing this map, the robot would push around these boxes as follows:
  #
  # Initial state:
  # ##############
  # ##......##..##
  # ##..........##
  # ##....[][]@.##
  # ##....[]....##
  # ##..........##
  # ##############
  #
  # Move <:
  # ##############
  # ##......##..##
  # ##..........##
  # ##...[][]@..##
  # ##....[]....##
  # ##..........##
  # ##############
  #
  # Move v:
  # ##############
  # ##......##..##
  # ##..........##
  # ##...[][]...##
  # ##....[].@..##
  # ##..........##
  # ##############
  #
  # Move v:
  # ##############
  # ##......##..##
  # ##..........##
  # ##...[][]...##
  # ##....[]....##
  # ##.......@..##
  # ##############
  #
  # Move <:
  # ##############
  # ##......##..##
  # ##..........##
  # ##...[][]...##
  # ##....[]....##
  # ##......@...##
  # ##############
  #
  # Move <:
  # ##############
  # ##......##..##
  # ##..........##
  # ##...[][]...##
  # ##....[]....##
  # ##.....@....##
  # ##############
  #
  # Move ^:
  # ##############
  # ##......##..##
  # ##...[][]...##
  # ##....[]....##
  # ##.....@....##
  # ##..........##
  # ##############
  #
  # Move ^:
  # ##############
  # ##......##..##
  # ##...[][]...##
  # ##....[]....##
  # ##.....@....##
  # ##..........##
  # ##############
  #
  # Move <:
  # ##############
  # ##......##..##
  # ##...[][]...##
  # ##....[]....##
  # ##....@.....##
  # ##..........##
  # ##############
  #
  # Move <:
  # ##############
  # ##......##..##
  # ##...[][]...##
  # ##....[]....##
  # ##...@......##
  # ##..........##
  # ##############
  #
  # Move ^:
  # ##############
  # ##......##..##
  # ##...[][]...##
  # ##...@[]....##
  # ##..........##
  # ##..........##
  # ##############
  #
  # Move ^:
  # ##############
  # ##...[].##..##
  # ##...@.[]...##
  # ##....[]....##
  # ##..........##
  # ##..........##
  # ##############
  #
  # This warehouse also uses GPS to locate the boxes. For these larger boxes, distances are measured from the edge of the map to the closest edge of the box in question. So, the box shown below has a distance of 1 from the top edge of the map and 5 from the left edge of the map, resulting in a GPS coordinate of 100 * 1 + 5 = 105.
  #
  # ##########
  # ##...[]...
  # ##........
  #
  # In the scaled-up version of the larger example from above, after the robot has finished all of its moves, the warehouse would look like this:
  #
  # ####################
  # ##[].......[].[][]##
  # ##[]...........[].##
  # ##[]........[][][]##
  # ##[]......[]....[]##
  # ##..##......[]....##
  # ##..[]............##
  # ##..@......[].[][]##
  # ##......[][]..[]..##
  # ####################
  #
  # The sum of these boxes' GPS coordinates is 9021.
  #
  # Predict the motion of the robot and boxes in this new, scaled-up warehouse. What is the sum of all boxes' final GPS coordinates?
  #
  # Your puzzle answer was 1548815.

  def sum_of_expanded_gps_coordinates(input) do
    input
    |> break_into_rows(true)
    |> expand_rows()
    |> parse()
    |> init()
    |> execute_moves()
    |> calculate_gps_coords()
    |> sum_gps_coords()
  end

  defp execute_moves(state) do
    state.moves
    |> Enum.reduce(state, fn move, state -> move(state, state.current_position, move) end)
  end

  defp move(state, coord, :up), do: move(state, coord, {0, -1}) |> elem(1)

  defp move(state, coord, :down), do: move(state, coord, {0, 1}) |> elem(1)

  defp move(state, coord, :left), do: move(state, coord, {-1, 0}) |> elem(1)

  defp move(state, coord, :right), do: move(state, coord, {1, 0}) |> elem(1)

  defp move(state, {x, y} = current_position, {dx, dy}) do
    new_position = {x + dx, y + dy}
    current_tile = Map.get(state.map, current_position)
    new_tile = Map.get(state.map, new_position)

    case new_tile do
      :wall ->
        {:stop, state}

      nil ->
        map =
          state.map
          |> Map.put(current_position, nil)
          |> Map.put(new_position, current_tile)

        state =
          state
          |> Map.put(:map, map)
          |> Map.put(:current_position, new_position)

        {:moved, state}

      :packet ->
        case move(state, new_position, {dx, dy}) do
          {:stop, state} ->
            {:stop, state}

          {:moved, state} ->
            map =
              state.map
              |> Map.put(current_position, nil)
              |> Map.put(new_position, current_tile)

            state =
              state
              |> Map.put(:map, map)
              |> Map.put(:current_position, new_position)

            {:moved, state}
        end

      t when t == :packet_l or t == :packet_r ->
        partner_position =
          if t == :packet_l do
            {x + dx + 1, y + dy}
          else
            {x + dx - 1, y + dy}
          end

        first_move =
          cond do
            dx < 0 && t == :packet_r -> partner_position
            dx > 0 && t == :packet_l -> partner_position
            true -> new_position
          end

        second_move =
          if first_move == new_position do
            partner_position
          else
            new_position
          end

        case move(state, first_move, {dx, dy}) do
          {:stop, state} ->
            {:stop, state}

          {:moved, new_state} ->
            case move(new_state, second_move, {dx, dy}) do
              {:stop, _} ->
                # Ignore the new state and propagate the old one
                # The new state contains the move of the partner block
                {:stop, state}

              {:moved, state} ->
                map =
                  state.map
                  |> Map.put(current_position, nil)
                  |> Map.put(new_position, current_tile)

                state =
                  state
                  |> Map.put(:map, map)
                  |> Map.put(:current_position, new_position)

                {:moved, state}
            end
        end

      _ ->
        raise "Invalid tile: #{new_tile}"
    end
  end

  defp sum_gps_coords(coords) do
    coords
    |> Map.values()
    |> sum()
  end

  defp calculate_gps_coords(state) do
    state.map
    |> Enum.filter(fn {_, v} -> v == :packet || v == :packet_l end)
    |> Enum.map(fn {{x, y} = coords, _} -> {coords, x + 100 * y} end)
    |> Enum.into(%{})
  end

  defp init(state) do
    robot_position =
      Enum.find(state.map, fn {_, v} -> v == :robot end)
      |> elem(0)

    state
    |> Map.put(:current_position, robot_position)
  end

  defp parse(rows) do
    rows
    |> Enum.reduce(
      {%{map: %{}, moves: []}, :map},
      fn
        "", {state, :map} ->
          {state, :moves}

        "", {state, :moves} ->
          {state, :map}

        row, {state, :moves} ->
          moves =
            row
            |> String.graphemes()
            |> Enum.reduce(
              [],
              fn
                "^", moves -> [:up | moves]
                "<", moves -> [:left | moves]
                ">", moves -> [:right | moves]
                "v", moves -> [:down | moves]
              end
            )
            |> Enum.reverse()

          state = Map.update(state, :moves, moves, fn old_moves -> old_moves ++ moves end)

          {state, :moves}

        row, {state, :map} ->
          state =
            state
            |> Map.put(:width, max(0, String.length(row) - 1))
            |> Map.update(:height, 0, &(&1 + 1))

          map =
            row
            |> String.graphemes()
            |> Enum.with_index()
            |> Enum.reduce(
              state.map,
              fn
                {"#", x}, map -> Map.put(map, {x, state.height}, :wall)
                {"O", x}, map -> Map.put(map, {x, state.height}, :packet)
                {"[", x}, map -> Map.put(map, {x, state.height}, :packet_l)
                {"]", x}, map -> Map.put(map, {x, state.height}, :packet_r)
                {"@", x}, map -> Map.put(map, {x, state.height}, :robot)
                {".", _}, map -> map
              end
            )

          state =
            state
            |> Map.put(:map, map)

          {state, :map}
      end
    )
    |> elem(0)
  end

  defp expand_rows(rows) do
    rows
    |> Enum.map(fn row ->
      row
      |> replace(~r/#/, "##")
      |> replace(~r/O/, "[]")
      |> replace(~r/\./, "..")
      |> replace(~r/@/, "@.")
    end)
  end

  # defp inspect_state(state) do
  #   for y <- 0..state.height do
  #     for x <- 0..state.width do
  #       case Map.get(state.map, {x, y}) do
  #         :wall -> IO.write("#")
  #         :packet -> IO.write("O")
  #         :packet_l -> IO.write("[")
  #         :packet_r -> IO.write("]")
  #         :robot -> IO.write("@")
  #         nil -> IO.write(".")
  #       end
  #     end
  #
  #     IO.puts("")
  #   end
  #
  #   state
  # end
end
