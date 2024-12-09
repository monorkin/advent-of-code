defmodule AdventOfCode.Day9Test do
  use ExUnit.Case

  test "correctly calculates the filesystem checksum after compaction" do
    input = """
    2333133121414131402
    """

    assert(AdventOfCode.Day9.fs_checksum_after_compaction(input) == 1928)
  end

  test "correctly calculates the filesystem checksum after defragmentation" do
    input = """
    2333133121414131402
    """

    assert(AdventOfCode.Day9.fs_checksum_after_defragmentation(input) == 2858)
  end
end
