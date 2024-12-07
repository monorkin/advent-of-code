defmodule AdventOfCode.Day7Test do
  use ExUnit.Case

  test "correctly finds the total calibration result" do
    input = """
    190: 10 19
    3267: 81 40 27
    83: 17 5
    156: 15 6
    7290: 6 8 6 15
    161011: 16 10 13
    192: 17 8 14
    21037: 9 7 18 13
    292: 11 6 16 20
    """

    assert(AdventOfCode.Day7.find_total_calibration_result(input, false) == 3749)
  end

  test "correctly finds the total calibration result with concatenations enabled" do
    input = """
    190: 10 19
    3267: 81 40 27
    83: 17 5
    156: 15 6
    7290: 6 8 6 15
    161011: 16 10 13
    192: 17 8 14
    21037: 9 7 18 13
    292: 11 6 16 20
    """

    assert(AdventOfCode.Day7.find_total_calibration_result(input, true) == 11387)
  end
end
