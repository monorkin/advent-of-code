defmodule AdventOfCode.Day17Test do
  use ExUnit.Case

  test "correctly executes the program and returns its output" do
    input = """
    Register A: 729
    Register B: 0
    Register C: 0

    Program: 0,1,5,4,3,0
    """

    assert(AdventOfCode.Day17.output_of(input) == "4,6,3,5,6,3,5,2,1,0")
  end

  test "correctly corrects the initial value of the A register so that the program outputs itself" do
    assert(AdventOfCode.Day17.correct() == 117_440)
  end
end
