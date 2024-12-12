defmodule AdventOfCode.Day12Test do
  use ExUnit.Case

  test "correctly counts calculates the price of fencing required" do
    input = """
    AAAA
    BBCD
    BBCC
    EEEC
    """

    assert(AdventOfCode.Day12.calculate_total_fencing_price(input, false) == 140)

    input = """
    OOOOO
    OXOXO
    OOOOO
    OXOXO
    OOOOO
    """

    assert(AdventOfCode.Day12.calculate_total_fencing_price(input, false) == 772)

    input = """
    RRRRIICCFF
    RRRRIICCCF
    VVRRRCCFFF
    VVRCCCJFFF
    VVVVCJJCFE
    VVIVCCJJEE
    VVIIICJJEE
    MIIIIIJJEE
    MIIISIJEEE
    MMMISSJEEE
    """

    assert(AdventOfCode.Day12.calculate_total_fencing_price(input, false) == 1930)
  end

  test "correctly counts calculates the price of fencing required with the bulk discount applied" do
    input = """
    AAAA
    BBCD
    BBCC
    EEEC
    """

    assert(AdventOfCode.Day12.calculate_total_fencing_price(input, true) == 80)

    input = """
    OOOOO
    OXOXO
    OOOOO
    OXOXO
    OOOOO
    """

    assert(AdventOfCode.Day12.calculate_total_fencing_price(input, true) == 436)

    input = """
    EEEEE
    EXXXX
    EEEEE
    EXXXX
    EEEEE
    """

    assert(AdventOfCode.Day12.calculate_total_fencing_price(input, true) == 236)

    input = """
    AAAAAA
    AAABBA
    AAABBA
    ABBAAA
    ABBAAA
    AAAAAA
    """

    assert(AdventOfCode.Day12.calculate_total_fencing_price(input, true) == 368)

    input = """
    RRRRIICCFF
    RRRRIICCCF
    VVRRRCCFFF
    VVRCCCJFFF
    VVVVCJJCFE
    VVIVCCJJEE
    VVIIICJJEE
    MIIIIIJJEE
    MIIISIJEEE
    MMMISSJEEE
    """

    assert(AdventOfCode.Day12.calculate_total_fencing_price(input, true) == 1206)
  end
end
