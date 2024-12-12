defmodule AdventOfCode.Day09 do
  import AdventOfCode.Utils

  # --- Day 9: Disk Fragmenter ---
  #
  # Another push of the button leaves you in the familiar hallways of some friendly amphipods! Good thing you each somehow got your own personal mini submarine. The Historians jet away in search of the Chief, mostly by driving directly into walls.
  #
  # While The Historians quickly figure out how to pilot these things, you notice an amphipod in the corner struggling with his computer. He's trying to make more contiguous free space by compacting all of the files, but his program isn't working; you offer to help.
  #
  # He shows you the disk map (your puzzle input) he's already generated. For example:
  #
  # 2333133121414131402
  #
  # The disk map uses a dense format to represent the layout of files and free space on the disk. The digits alternate between indicating the length of a file and the length of free space.
  #
  # So, a disk map like 12345 would represent a one-block file, two blocks of free space, a three-block file, four blocks of free space, and then a five-block file. A disk map like 90909 would represent three nine-block files in a row (with no free space between them).
  #
  # Each file on disk also has an ID number based on the order of the files as they appear before they are rearranged, starting with ID 0. So, the disk map 12345 has three files: a one-block file with ID 0, a three-block file with ID 1, and a five-block file with ID 2. Using one character for each block where digits are the file ID and . is free space, the disk map 12345 represents these individual blocks:
  #
  # 0..111....22222
  #
  # The first example above, 2333133121414131402, represents these individual blocks:
  #
  # 00...111...2...333.44.5555.6666.777.888899
  #
  # The amphipod would like to move file blocks one at a time from the end of the disk to the leftmost free space block (until there are no gaps remaining between file blocks). For the disk map 12345, the process looks like this:
  #
  # 0..111....22222
  # 02.111....2222.
  # 022111....222..
  # 0221112...22...
  # 02211122..2....
  # 022111222......
  #
  # The first example requires a few more steps:
  #
  # 00...111...2...333.44.5555.6666.777.888899
  # 009..111...2...333.44.5555.6666.777.88889.
  # 0099.111...2...333.44.5555.6666.777.8888..
  # 00998111...2...333.44.5555.6666.777.888...
  # 009981118..2...333.44.5555.6666.777.88....
  # 0099811188.2...333.44.5555.6666.777.8.....
  # 009981118882...333.44.5555.6666.777.......
  # 0099811188827..333.44.5555.6666.77........
  # 00998111888277.333.44.5555.6666.7.........
  # 009981118882777333.44.5555.6666...........
  # 009981118882777333644.5555.666............
  # 00998111888277733364465555.66.............
  # 0099811188827773336446555566..............
  #
  # The final step of this file-compacting process is to update the filesystem checksum. To calculate the checksum, add up the result of multiplying each of these blocks' position with the file ID number it contains. The leftmost block is in position 0. If a block contains free space, skip it instead.
  #
  # Continuing the first example, the first few blocks' position multiplied by its file ID number are 0 * 0 = 0, 1 * 0 = 0, 2 * 9 = 18, 3 * 9 = 27, 4 * 8 = 32, and so on. In this example, the checksum is the sum of these, 1928.
  #
  # Compact the amphipod's hard drive using the process he requested. What is the resulting filesystem checksum? (Be careful copy/pasting the input for this puzzle; it is a single, very long line.)
  #
  # Your puzzle answer was 6341711060162.

  def fs_checksum_after_compaction(input) do
    input
    |> parse()
    |> compress()
    |> compute_checksum()
  end

  # --- Part Two ---
  #
  # Upon completion, two things immediately become clear. First, the disk definitely has a lot more contiguous free space, just like the amphipod hoped. Second, the computer is running much more slowly! Maybe introducing all of that file system fragmentation was a bad idea?
  #
  # The eager amphipod already has a new plan: rather than move individual blocks, he'd like to try compacting the files on his disk by moving whole files instead.
  #
  # This time, attempt to move whole files to the leftmost span of free space blocks that could fit the file. Attempt to move each file exactly once in order of decreasing file ID number starting with the file with the highest file ID number. If there is no span of free space to the left of a file that is large enough to fit the file, the file does not move.
  #
  # The first example from above now proceeds differently:
  #
  # 00...111...2...333.44.5555.6666.777.888899
  # 0099.111...2...333.44.5555.6666.777.8888..
  # 0099.1117772...333.44.5555.6666.....8888..
  # 0099.111777244.333....5555.6666.....8888..
  # 00992111777.44.333....5555.6666.....8888..
  #
  # The process of updating the filesystem checksum is the same; now, this example's checksum would be 2858.
  #
  # Start over, now compacting the amphipod's hard drive using this new method instead. What is the resulting filesystem checksum?
  #
  # Your puzzle answer was 6377400869326.

  def fs_checksum_after_defragmentation(input) do
    input
    |> parse()
    |> defragment()
    |> compute_checksum()
  end

  defp defragment(fs) do
    # Adds a tag which indicates if the block was previously moved or not
    # Leading file blocks - the ones without a freespace before them -
    # as they can't be moved are auto-tagged as moved
    tagged_fs =
      fs
      |> Enum.reduce({[], false}, fn block, {new_fs, available_free_block} ->
        case {block, available_free_block} do
          {{:file, _, _}, false} ->
            {[{block, true} | new_fs], false}

          {{:file, _, _}, true} ->
            {[{block, false} | new_fs], true}

          _ ->
            {[{block, false} | new_fs], available_free_block || true}
        end
      end)
      |> elem(0)
      |> Enum.reverse()

    {{:file, _, id}, _} =
      tagged_fs
      |> Enum.max_by(fn
        {{:file, _, id}, false} -> id
        _ -> 0
      end)

    defragment(tagged_fs, id)
  end

  # We've processed the last file ID
  # Return whatever we've accumulated so far
  defp defragment(tagged_fs, id) when is_integer(id) and id < 0 do
    defragment(tagged_fs, nil)
  end

  defp defragment(tagged_fs, nil) do
    Enum.map(
      tagged_fs,
      fn
        {block, _} -> block
        {_, _, _} = block -> block
      end
    )
  end

  # Skip previously moved files
  defp defragment(tagged_fs, {{{:file, _, id}, true}, _}) do
    defragment(tagged_fs, id - 1)
  end

  # Defragment unmoved file
  defp defragment(tagged_fs, {{{:file, len, id}, false}, i}) do
    indexed_and_tagged_fs = tagged_fs |> Enum.with_index()

    freespace =
      indexed_and_tagged_fs
      |> Enum.find(fn
        {{{:freespace, size, _}, _}, j} when size >= len and j < i -> true
        _ -> false
      end)

    if is_nil(freespace) do
      # There is no free space for this file, tag the block as moved
      indexed_and_tagged_fs
      |> Enum.map(fn
        {{{:file, ^len, ^id}, false}, ^i} -> {{:file, len, id}, true}
        {tagged_block, _} -> tagged_block
      end)
    else
      {{{_, _, _} = freespace_block, _}, fi} = freespace
      # Move the file to the free space
      fill(tagged_fs, {freespace_block, fi}, {{:file, len, id}, i})
    end
    |> defragment(id - 1)
  end

  # Convert integer IDs to files and add the index of the block
  defp defragment(tagged_fs, id) when is_integer(id) do
    file =
      tagged_fs
      |> Enum.with_index()
      |> Enum.find(fn
        {{{:file, _, ^id}, false}, _} -> true
        _ -> false
      end)

    if is_nil(file) do
      defragment(tagged_fs, id - 1)
    else
      defragment(tagged_fs, file)
    end
  end

  defp compress(fs) do
    freespace_left =
      Enum.count(fs, fn
        {:freespace, _, _} -> true
        _ -> false
      end)

    if freespace_left <= 1 do
      fs
    else
      first_freespace_index =
        find_index(fs, fn
          {:freespace, _, _} -> true
          _ -> false
        end)

      last_file_index =
        find_last_index(
          fs,
          fn
            {:file, _, _} -> true
            _ -> false
          end
        )

      fs
      |> fill(first_freespace_index, last_file_index)
      |> compress()
    end
  end

  defp fill(fs, {{btf_type, btf_len, btf_id} = btf, btf_i}, {{fb_type, fb_len, fb_id} = fb, fb_i}) do
    {new_btfs, new_fb} =
      cond do
        # If the block are of the same size
        # Swap the block to fill with the filler block
        btf_len == fb_len ->
          {[fb], [btf]}

        # If the block to fill is larger than the filler block
        # Split the block to fill into two blocks - one to the
        # filler block, and the other for the remainder of the
        # block to fill - then remove the filler block
        btf_len > fb_len ->
          {
            [
              {fb_type, fb_len, fb_id},
              {btf_type, btf_len - fb_len, btf_id}
            ],
            [{btf_type, fb_len, btf_id}]
          }

        # If the block to fill is smaller than the filler block
        # Convert the block to fill to be of the same type and id
        # as the filler block, and make the filler block smaller
        btf_len < fb_len ->
          {
            [{fb_type, btf_len, fb_id}],
            [
              {fb_type, fb_len - btf_len, fb_id},
              {btf_type, btf_len, btf_id}
            ]
          }
      end

    fs
    |> Enum.with_index()
    |> Enum.flat_map(fn
      {{_, _}, ^btf_i} -> Enum.map(new_btfs, fn block -> {block, true} end)
      {_, ^btf_i} -> new_btfs
      {{_, _}, ^fb_i} -> Enum.map(new_fb, fn block -> {block, true} end)
      {_, ^fb_i} -> new_fb
      {block, _} -> [block]
    end)
    |> Enum.reduce([], fn
      block, [] ->
        [block]

      {:freespace, len, _}, [{:freespace, old_len, id} | rest_fs] ->
        [{:freespace, old_len + len, id} | rest_fs]

      {{:freespace, len, _}, _}, [{{:freespace, old_len, id}, moved} | rest_fs] ->
        [{{:freespace, old_len + len, id}, moved} | rest_fs]

      {:file, len, id}, [{:file, prev_len, prev_id} | rest_fs] when id == prev_id ->
        [{:file, prev_len + len, prev_id} | rest_fs]

      {{:file, len, id}, _}, [{{:file, prev_len, prev_id}, moved} | rest_fs] when id == prev_id ->
        [{{:file, prev_len + len, prev_id}, moved} | rest_fs]

      block, fs ->
        [block | fs]
    end)
    |> Enum.reverse()
  end

  defp join_files(fs) do
    fs
    |> join_blocks(fn
      {{:file, _, _}, _} = cb, {state, nil} ->
        {state, {cb, cb}}

      {{:file, len, id}, _} = cb, {state, {ob, {{nb_type, nb_len, nb_id}, nb_i}}}
      when id == nb_id ->
        state = Map.update(state, :deletions, [], &[cb | &1])
        {state, {ob, {{nb_type, nb_len + len, nb_id}, nb_i}}}

      {{:file, _, _}, _} = cb, {state, {ob, nb}} ->
        state = Map.update(state, :substitutions, %{}, &Map.put(&1, ob, nb))
        {state, {cb, cb}}

      {_, _}, {state, nil} ->
        {state, nil}

      {_, _}, {state, {ob, nb}} ->
        state = Map.update(state, :substitutions, %{}, &Map.put(&1, ob, nb))
        {state, nil}
    end)
  end

  defp join_freespaces(fs) do
    fs
    |> join_blocks(fn
      {{:freespace, _, _}, _} = cb, {state, nil} ->
        {state, {cb, cb}}

      {{:freespace, len, _}, _} = cb, {state, {ob, {{nb_type, nb_len, nb_id}, nb_i}}} ->
        state = Map.update(state, :deletions, [], &[cb | &1])
        {state, {ob, {{nb_type, nb_len + len, nb_id}, nb_i}}}

      {_, _}, {state, nil} ->
        {state, nil}

      {_, _}, {state, {ob, nb}} ->
        state = Map.update(state, :substitutions, %{}, &Map.put(&1, ob, nb))
        {state, nil}
    end)
  end

  defp join_blocks(fs, joiner) do
    {state, sub} =
      fs
      |> Enum.with_index()
      |> Enum.reduce({%{substitutions: %{}, deletions: []}, nil}, joiner)

    state =
      if sub do
        Map.update(state, :substitutions, %{}, &Map.put(&1, elem(sub, 0), elem(sub, 1)))
      else
        state
      end

    fs
    |> Enum.with_index()
    |> Enum.map(fn
      cb ->
        cond do
          state.substitutions[cb] ->
            {block, _} = state.substitutions[cb]
            block

          cb in state.deletions ->
            nil

          true ->
            {block, _} = cb
            block
        end
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp compute_checksum(fs) do
    fs
    |> Enum.reduce({0, 0}, fn
      {:file, len, id}, {sum, i} ->
        block_sum = Enum.reduce(i..(i + len - 1), 0, fn x, acc -> acc + x * id end)
        {sum + block_sum, i + len}

      {:freespace, len, _}, {sum, i} ->
        {sum, i + len}
    end)
    |> elem(0)
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.graphemes()
    |> Enum.reduce({[], :file, 0}, fn char, {fs, type, id} ->
      {len, ""} = Integer.parse(char)
      next_type = if type == :file, do: :freespace, else: :file

      cond do
        len == 0 and type == :file ->
          {fs, next_type, id + 1}

        len == 0 and type == :freespace ->
          {fs, next_type, id}

        type == :file ->
          {[{:file, len, id} | fs], next_type, id + 1}

        true ->
          {[{:freespace, len, id} | fs], next_type, id}
      end
    end)
    |> elem(0)
    |> Enum.reverse()
    |> join_freespaces()
    |> join_files()
  end

  # defp inspect_fs(fs, stats) do
  #   label = Keyword.get(stats, :label, nil)
  #   render = Keyword.get(stats, :render, false)
  #   info = Keyword.get(stats, :info, false)
  #
  #   if label do
  #     IO.puts("-- #{label} --")
  #   end
  #
  #   if render do
  #     Enum.each(fs, fn
  #       {:file, len, id} ->
  #         id = Integer.to_string(id)
  #         IO.write(String.pad_leading(id, len, id))
  #
  #       {:freespace, len, _} ->
  #         IO.write(String.pad_leading(".", len, "."))
  #     end)
  #
  #     IO.puts("")
  #   end
  #
  #   if info do
  #     blocks = Enum.count(fs)
  #
  #     freespace =
  #       Enum.count(fs, fn
  #         {:freespace, _, _} -> true
  #         _ -> false
  #       end)
  #
  #     files = blocks - freespace
  #     size = Enum.reduce(fs, 0, fn {_, len, _}, acc -> acc + len end)
  #
  #     used =
  #       Enum.reduce(fs, 0, fn
  #         {:file, len, _}, acc -> acc + len
  #         _, acc -> acc
  #       end)
  #
  #     free = size - used
  #
  #     IO.puts("Blocks")
  #     IO.puts("  Total: #{blocks}")
  #     IO.puts("  Files: #{files}")
  #     IO.puts("  Freespace: #{freespace}")
  #     IO.puts("Size")
  #     IO.puts("  Total: #{size}")
  #     IO.puts("  Used: #{used}")
  #     IO.puts("  Free: #{free}")
  #   end
  #
  #   fs
  # end
end
