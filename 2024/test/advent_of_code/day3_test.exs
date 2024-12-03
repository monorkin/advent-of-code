defmodule AdventOfCode.Day3Test do
  use ExUnit.Case

  test "executes uncorruped muls correctly" do
    input = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"

    # (2*4 + 5*5 + 11*8 + 8*5) = 161
    assert(assert AdventOfCode.Day3.execute_uncorrupted_muls(input) == 161)
  end

  test "executes uncorrupted muls with conditionals correctly" do
    input = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

    # (2*4 + 8*5) = 48
    assert(AdventOfCode.Day3.execute_uncorrupted_with_conditionals_muls(input) == 48)
  end
end
