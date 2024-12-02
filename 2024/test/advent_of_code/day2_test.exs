defmodule AdventOfCode.Day2Test do
  use ExUnit.Case

  test "calculates the number of safe reports correctly" do
    input = """
    7 6 4 2 1
    1 2 7 8 9
    9 7 6 2 1
    1 3 2 4 5
    8 6 4 4 1
    1 3 6 7 9
    """

    assert(assert AdventOfCode.Day2.count_safe_reports(input, false) == 2)
  end

  test "calculates the number of safe reports with the problem dampener correctly" do
    input = """
    7 6 4 2 1
    1 2 7 8 9
    9 7 6 2 1
    1 3 2 4 5
    8 6 4 4 1
    1 3 6 7 9
    """

    assert AdventOfCode.Day2.count_safe_reports(input, true) == 4
  end
end
