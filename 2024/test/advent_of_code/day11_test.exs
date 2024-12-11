defmodule AdventOfCode.Day10Test do
  use ExUnit.Case

  test "correctly counts stone arrangements after 25 blinks" do
    input = """
    125 17
    """

    assert(AdventOfCode.Day11.count_stone_arrangements_after(input, 25) == 55312)
  end

  test "correctly does fun2" do
    input = """
    125 17
    """

    assert(AdventOfCode.Day11.count_stone_arrangements_after(input, 75) == 65_601_038_650_482)
  end
end
