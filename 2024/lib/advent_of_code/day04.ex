defmodule AdventOfCode.Day04 do
  import AdventOfCode.Utils

  @xmas_regex ~r/XMAS/

  # --- Day 4: Ceres Search ---
  #
  # "Looks like the Chief's not here. Next!" One of The Historians pulls out a device and pushes the only button on it. After a brief flash, you recognize the interior of the Ceres monitoring station!
  #
  # As the search for the Chief continues, a small Elf who lives on the station tugs on your shirt; she'd like to know if you could help her with her word search (your puzzle input). She only has to find one word: XMAS.
  #
  # This word search allows words to be horizontal, vertical, diagonal, written backwards, or even overlapping other words. It's a little unusual, though, as you don't merely need to find one instance of XMAS - you need to find all of them. Here are a few ways XMAS might appear, where irrelevant characters have been replaced with .:
  #
  # ..X...
  # .SAMX.
  # .A..A.
  # XMAS.S
  # .X....
  #
  # The actual word search will be full of letters instead. For example:
  #
  # MMMSXXMASM
  # MSAMXMSMSA
  # AMXSXMAAMM
  # MSAMASMSMX
  # XMASAMXAMM
  # XXAMMXXAMA
  # SMSMSASXSS
  # SAXAMASAAA
  # MAMMMXMMMM
  # MXMXAXMASX
  #
  # In this word search, XMAS occurs a total of 18 times; here's the same word search again, but where letters not involved in any XMAS have been replaced with .:
  #
  # ....XXMAS.
  # .SAMXMS...
  # ...S..A...
  # ..A.A.MS.X
  # XMASAMX.MM
  # X.....XA.A
  # S.S.S.S.SS
  # .A.A.A.A.A
  # ..M.M.M.MM
  # .X.X.XMASX
  #
  # Take a look at the little Elf's word search. How many times does XMAS appear?
  #
  # Your puzzle answer was 2517.

  def find_all_occurances_of_xmas(input) do
    input
    |> break_into_rows()
    |> count_occurances_in_all_directions(fn matrix ->
      count_regex_matches(matrix, @xmas_regex)
    end)
  end

  # --- Part Two ---
  #
  # The Elf looks quizzically at you. Did you misunderstand the assignment?
  #
  # Looking for the instructions, you flip over the word search to find that this isn't actually an XMAS puzzle; it's an X-MAS puzzle in which you're supposed to find two MAS in the shape of an X. One way to achieve that is like this:
  #
  # M.S
  # .A.
  # M.S
  #
  # Irrelevant characters have again been replaced with . in the above diagram. Within the X, each MAS can be written forwards or backwards.
  #
  # Here's the same example from before, but this time all of the X-MASes have been kept instead:
  #
  # .M.S......
  # ..A..MSMS.
  # .M.S.MAA..
  # ..A.ASMSM.
  # .M.S.M....
  # ..........
  # S.S.S.S.S.
  # .A.A.A.A..
  # M.M.M.M.M.
  # ..........
  #
  # In this example, an X-MAS appears 9 times.
  #
  # Flip the word search from the instructions back over to the word search side and try again. How many times does an X-MAS appear?
  #
  # Your puzzle answer was 1960.

  def find_all_occurances_of_mas_in_the_shape_of_an_x(input) do
    counter = fn matrix ->
      horizontal = Enum.at(matrix, floor(length(matrix) / 2))

      vertical =
        Enum.map(matrix, fn row ->
          if rem(String.length(row), 2) == 0 do
            nil
          else
            String.at(row, floor(String.length(row) / 2))
          end
        end)
        |> Enum.reject(&is_nil/1)
        |> Enum.join()

      if (horizontal == "MAS" || horizontal == "SAM") &&
           (vertical == "MAS" || vertical == "SAM") do
        1
      else
        0
      end
    end

    input
    |> break_into_rows()
    |> count_occurances_in_window({3, 3}, fn window ->
      counter.(rotate(window, -45))
    end)
  end

  defp count_occurances_in_all_directions(input, counter) do
    left_to_right =
      input
      |> counter.()

    right_to_left =
      input
      |> flip()
      |> counter.()

    top_to_bottom =
      input
      |> rotate(90)
      |> counter.()

    bottom_to_top =
      input
      |> rotate(90)
      |> flip()
      |> counter.()

    top_left_to_bottom_right =
      input
      |> rotate(45)
      |> counter.()

    bottom_right_to_top_left =
      input
      |> rotate(45)
      |> flip()
      |> counter.()

    top_right_to_bottom_left =
      input
      |> rotate(-45)
      |> counter.()

    bottom_left_to_top_right =
      input
      |> rotate(-45)
      |> flip()
      |> counter.()

    [
      left_to_right,
      right_to_left,
      top_to_bottom,
      bottom_to_top,
      top_left_to_bottom_right,
      bottom_right_to_top_left,
      top_right_to_bottom_left,
      bottom_left_to_top_right
    ]
    |> sum()
  end

  defp count_regex_matches(input, regex) do
    input
    |> Enum.flat_map(fn row -> scan(row, regex) end)
    |> Enum.count()
  end

  defp flip(input) do
    input
    |> Enum.map(fn row -> String.reverse(row) end)
  end

  defp rotate(input, 90) do
    input
    |> Enum.map(fn row -> String.split(row, "", trim: true) end)
    |> transpose()
    |> Enum.map(fn row -> Enum.join(row, "") end)
  end

  defp rotate(input, 45) do
    height = length(input)
    width = String.length(List.first(input))

    # Convert strings to character matrix
    matrix =
      input
      |> Enum.map(&String.graphemes/1)

    # Calculate dimensions of output
    max_len = height + width - 1

    # Generate diagonals
    0..(max_len - 1)
    |> Enum.map(fn diagonal_idx ->
      # For each diagonal, collect characters at coordinates where x + y equals diagonal_idx
      chars =
        for y <- 0..(height - 1),
            x <- 0..(width - 1),
            x + y == diagonal_idx do
          row = Enum.at(matrix, y)
          if row, do: Enum.at(row, x)
        end

      # Filter out nils and join characters
      chars
      |> Enum.reject(&is_nil/1)
      |> Enum.join()
    end)
    |> Enum.reject(&(String.length(&1) == 0))
    |> Enum.reverse()
  end

  defp rotate(input, -45) do
    # First get the dimensions
    height = length(input)
    width = String.length(List.first(input))

    # Convert strings to character matrix
    matrix =
      input
      |> Enum.map(&String.graphemes/1)

    # Calculate dimensions of output
    max_len = height + width - 1

    # Generate diagonals
    0..(max_len - 1)
    |> Enum.map(fn diagonal_idx ->
      # For clockwise rotation, we collect characters where y - x equals diagonal_idx - (width - 1)
      chars =
        for y <- 0..(height - 1),
            x <- 0..(width - 1),
            y - x == diagonal_idx - (width - 1) do
          row = Enum.at(matrix, y)
          if row, do: Enum.at(row, x)
        end

      # Filter out nils and join characters
      chars
      |> Enum.reject(&is_nil/1)
      |> Enum.join()
    end)
    |> Enum.reject(&(String.length(&1) == 0))
  end

  defp transpose(matrix) do
    matrix
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  defp count_occurances_in_window(input, {window_width, window_height}, counter) do
    height = length(input)
    width = String.length(List.first(input))

    for y <- 0..(height - window_height),
        x <- 0..(width - window_width) do
      window =
        for window_y <- 0..(window_height - 1) do
          Enum.at(input, y + window_y)
          |> String.slice(x..(x + window_width - 1))
        end

      counter.(window)
    end
    |> sum()
  end
end
