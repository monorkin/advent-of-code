defmodule AdventOfCode.Day10Test do
  use ExUnit.Case

  test "correctly calculates the sum of all trailhead scores" do
    input = """
    89010123
    78121874
    87430965
    96549874
    45678903
    32019012
    01329801
    10456732
    """

    assert(AdventOfCode.Day10.calculate_sum_of_trailhead_scores(input) == 36)
  end

  test "correctly calculates the sum of all trailhead ratings" do
    input = """
    89010123
    78121874
    87430965
    96549874
    45678903
    32019012
    01329801
    10456732
    """

    assert(AdventOfCode.Day10.calculate_sum_of_trailhead_ratings(input) == 81)
  end
end
