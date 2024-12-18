defmodule AdventOfCode.Day18Test do
  use ExUnit.Case

  test "correctly finds the shortest path" do
    input = """
    5,4
    4,2
    4,5
    3,0
    2,1
    6,3
    2,4
    1,5
    0,6
    3,3
    2,6
    5,1
    1,2
    5,5
    2,5
    6,5
    1,4
    0,4
    6,4
    1,1
    6,1
    1,0
    0,5
    1,6
    2,0
    """

    assert(AdventOfCode.Day18.shortest_path(input, {6, 6}, 12) == 22)
  end
end