defmodule AdventOfCode.Day01Test do
  use ExUnit.Case

  test "calculates the total distance correctly" do
    input = """
    3   4
    4   3
    2   5
    1   3
    3   9
    3   3
    """

    assert AdventOfCode.Day01.calculate_total_distance(input) == 11
  end

  test "calculates the similarity score correctly" do
    input = """
    3   4
    4   3
    2   5
    1   3
    3   9
    3   3
    """

    assert AdventOfCode.Day01.calculate_similarity_score(input) == 31
  end
end
