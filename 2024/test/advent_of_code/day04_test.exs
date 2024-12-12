defmodule AdventOfCode.Day04Test do
  use ExUnit.Case

  test "finds all the XMAS strings in the grid" do
    input = """
    MMMSXXMASM
    MSAMXMSMSA
    AMXSXMAAMM
    MSAMASMSMX
    XMASAMXAMM
    XXAMMXXAMA
    SMSMSASXSS
    SAXAMASAAA
    MAMMMXMMMM
    MXMXAXMASX
    """

    assert(AdventOfCode.Day04.find_all_occurances_of_xmas(input) == 18)
  end

  test "finds all the MAS strings in the shape of an X" do
    input = """
    MMMSXXMASM
    MSAMXMSMSA
    AMXSXMAAMM
    MSAMASMSMX
    XMASAMXAMM
    XXAMMXXAMA
    SMSMSASXSS
    SAXAMASAAA
    MAMMMXMMMM
    MXMXAXMASX
    """

    assert(AdventOfCode.Day04.find_all_occurances_of_mas_in_the_shape_of_an_x(input) == 9)
  end
end
