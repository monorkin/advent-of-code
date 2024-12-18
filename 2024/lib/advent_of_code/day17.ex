defmodule AdventOfCode.Day17 do
  import AdventOfCode.Utils
  import Bitwise

  # --- Day 17: Chronospatial Computer ---
  #
  # The Historians push the button on their strange device, but this time, you all just feel like you're falling.
  #
  # "Situation critical", the device announces in a familiar voice. "Bootstrapping process failed. Initializing debugger...."
  #
  # The small handheld device suddenly unfolds into an entire computer! The Historians look around nervously before one of them tosses it to you.
  #
  # This seems to be a 3-bit computer: its program is a list of 3-bit numbers (0 through 7), like 0,1,2,3. The computer also has three registers named A, B, and C, but these registers aren't limited to 3 bits and can instead hold any integer.
  #
  # The computer knows eight instructions, each identified by a 3-bit number (called the instruction's opcode). Each instruction also reads the 3-bit number after it as an input; this is called its operand.
  #
  # A number called the instruction pointer identifies the position in the program from which the next opcode will be read; it starts at 0, pointing at the first 3-bit number in the program. Except for jump instructions, the instruction pointer increases by 2 after each instruction is processed (to move past the instruction's opcode and its operand). If the computer tries to read an opcode past the end of the program, it instead halts.
  #
  # So, the program 0,1,2,3 would run the instruction whose opcode is 0 and pass it the operand 1, then run the instruction having opcode 2 and pass it the operand 3, then halt.
  #
  # There are two types of operands; each instruction specifies the type of its operand. The value of a literal operand is the operand itself. For example, the value of the literal operand 7 is the number 7. The value of a combo operand can be found as follows:
  #
  #     Combo operands 0 through 3 represent literal values 0 through 3.
  #     Combo operand 4 represents the value of register A.
  #     Combo operand 5 represents the value of register B.
  #     Combo operand 6 represents the value of register C.
  #     Combo operand 7 is reserved and will not appear in valid programs.
  #
  # The eight instructions are as follows:
  #
  # The adv instruction (opcode 0) performs division. The numerator is the value in the A register. The denominator is found by raising 2 to the power of the instruction's combo operand. (So, an operand of 2 would divide A by 4 (2^2); an operand of 5 would divide A by 2^B.) The result of the division operation is truncated to an integer and then written to the A register.
  #
  # The bxl instruction (opcode 1) calculates the bitwise XOR of register B and the instruction's literal operand, then stores the result in register B.
  #
  # The bst instruction (opcode 2) calculates the value of its combo operand modulo 8 (thereby keeping only its lowest 3 bits), then writes that value to the B register.
  #
  # The jnz instruction (opcode 3) does nothing if the A register is 0. However, if the A register is not zero, it jumps by setting the instruction pointer to the value of its literal operand; if this instruction jumps, the instruction pointer is not increased by 2 after this instruction.
  #
  # The bxc instruction (opcode 4) calculates the bitwise XOR of register B and register C, then stores the result in register B. (For legacy reasons, this instruction reads an operand but ignores it.)
  #
  # The out instruction (opcode 5) calculates the value of its combo operand modulo 8, then outputs that value. (If a program outputs multiple values, they are separated by commas.)
  #
  # The bdv instruction (opcode 6) works exactly like the adv instruction except that the result is stored in the B register. (The numerator is still read from the A register.)
  #
  # The cdv instruction (opcode 7) works exactly like the adv instruction except that the result is stored in the C register. (The numerator is still read from the A register.)
  #
  # Here are some examples of instruction operation:
  #
  #     If register C contains 9, the program 2,6 would set register B to 1.
  #     If register A contains 10, the program 5,0,5,1,5,4 would output 0,1,2.
  #     If register A contains 2024, the program 0,1,5,4,3,0 would output 4,2,5,6,7,7,7,7,3,1,0 and leave 0 in register A.
  #     If register B contains 29, the program 1,7 would set register B to 26.
  #     If register B contains 2024 and register C contains 43690, the program 4,0 would set register B to 44354.
  #
  # The Historians' strange device has finished initializing its debugger and is displaying some information about the program it is trying to run (your puzzle input). For example:
  #
  # Register A: 729
  # Register B: 0
  # Register C: 0
  #
  # Program: 0,1,5,4,3,0
  #
  # Your first task is to determine what the program is trying to output. To do this, initialize the registers to the given values, then run the given program, collecting any output produced by out instructions. (Always join the values produced by out instructions with commas.) After the above program halts, its final output will be 4,6,3,5,6,3,5,2,1,0.
  #
  # Using the information provided by the debugger, initialize the registers to the given values, then run the program. Once it halts, what do you get if you use commas to join the values it output into a single string?
  #
  # Your puzzle answer was 7,6,5,3,6,5,7,0,4.

  def output_of(input) do
    state =
      input
      |> parse()
      |> execute()

    state.output
    |> Enum.join(",")
  end

  def correct() do
    # input = """
    # Register A: 27334280
    # Register B: 0
    # Register C: 0
    #
    # Program: 2,4,1,2,7,5,0,3,1,7,4,1,5,5,3,0
    # """

    # state =
    #   input
    #   |> parse()

    # Program:
    # {2, 4} B = A % 8
    # {1, 2} B = B ^ 2
    # {7, 5} C = A / exp(2, B)
    # {0, 3} A = A / 8; This stops the loop
    # {1, 7} B = B ^ 7
    # {4, 1} B = B ^ C
    # {5, 5} print(B % 8)
    # {3, 0} loop while A != 0

    # After applying commutativity and associativity we can simplify the program to:
    # B = (7 ^ ((A % 8) ^ 2) ^ (A / 2^((A % 8) ^ 2))) % 8

    # The loop has to stop in exactly 16 iterations because it has
    # to print 16 characteres - 2,4,1,2,7,5,0,3,1,7,4,1,5,5,3,0
    # That means that I have to divide A by 8 exactly 16 times before it becomes 0
    # A neat quirk of binary numbers is that division by 8 is the same as right shifting 3 times
    # Since I'm working with 3 bit numbers that means that A is just the concatenation of the 16 characters
    # min_a = Integer.pow(2, 15)
    # max_a = Integer.pow(2, 16)

    # b = fn a ->
    #   low_a = rem(a, 8)
    #
    #   rem(
    #     bxor(
    #       7,
    #       bxor(
    #         bxor(
    #           low_a,
    #           2
    #         ),
    #         floor(
    #           div(
    #             a,
    #             Integer.pow(
    #               2,
    #               bxor(
    #                 low_a,
    #                 2
    #               )
    #             )
    #           )
    #         )
    #       )
    #     ),
    #     8
    #   )
    # end
    #
    # pack = fn numbers ->
    #   numbers
    #   |> Enum.reduce(0, fn num, acc ->
    #     # Shift left by 3 bits and add new number (masked to 3 bits)
    #     acc <<< 3 ||| (num &&& 0b111)
    #   end)
    # end
  end

  # def reverse_hash(output, a \\ 0, position \\ 0, mask \\ 0xFFFFFFFF)
  #
  # def reverse_hash([], a, _position, _mask), do: {:ok, a}
  #
  # def reverse_hash([b | rest], a, position, mask) do
  #   current_mask = mask >>> position
  #   a_mask = rem(current_mask, 8)
  #   b_inv = bxor(b, 7)
  #   current_a = a >>> position
  #
  #   candidate_as =
  #     0..7
  #     |> Enum.map(fn candidate_a_tick -> candidate_a_tick &&& a_mask end)
  #     |> Enum.uniq()
  #     |> Enum.map(fn a_tick ->
  #       result = 7
  #
  #       if b_inv == result do
  #         new_current_a = bxor(a_tick, 2)
  #         a &&& (0xFFFFFFFF - current_mask ||| new_current_a <<< position)
  #       else
  #         nil
  #       end
  #     end)
  #     |> Enum.reject(&is_nil/1)
  #
  #   if length(candidate_as) == 0 do
  #     {:error, :no_valid_result_found}
  #   else
  #     new_mask = mask &&& 0xFFFFFFFF - current_mask
  #     new_position = position + 3
  #     reverse_hash(rest, Enum.min(candidate_as), new_position, new_mask)
  #   end
  # end

  defp execute(state) do
    instruction = Enum.at(state.program, state.program_counter)
    operand = Enum.at(state.program, state.program_counter + 1)

    result =
      case instruction do
        nil -> {:halt, state}
        0 -> exec_adv(state, operand)
        1 -> exec_bxl(state, operand)
        2 -> exec_bst(state, operand)
        3 -> exec_jnz(state, operand)
        4 -> exec_bxc(state, operand)
        5 -> exec_out(state, operand)
        6 -> exec_bdv(state, operand)
        7 -> exec_cdv(state, operand)
      end

    case result do
      {:halt, state} ->
        state

      {:continue, state} ->
        state = Map.put(state, :program_counter, state.program_counter + 2)
        execute(state)

      {:jump, state} ->
        execute(state)
    end
  end

  defp exec_out(state, combo_operand) do
    result =
      combo_operator_value(state, combo_operand)
      |> rem(8)

    state = Map.put(state, :output, state.output ++ [result])
    {:continue, state}
  end

  defp exec_bxc(state, _) do
    result = bxor(state.register_b, state.register_c)
    {:continue, Map.put(state, :register_b, result)}
  end

  defp exec_bxl(state, operand) do
    result = bxor(state.register_b, operand)
    {:continue, Map.put(state, :register_b, result)}
  end

  defp exec_jnz(state, operand) do
    if state.register_a == 0 do
      {:continue, state}
    else
      state = Map.put(state, :program_counter, operand)
      {:jump, state}
    end
  end

  defp exec_bst(state, combo_operand) do
    result =
      combo_operator_value(state, combo_operand)
      |> rem(8)

    {:continue, Map.put(state, :register_b, result)}
  end

  defp exec_adv(state, combo_operand) do
    {:continue, Map.put(state, :register_a, _dv(state, combo_operand))}
  end

  defp exec_cdv(state, combo_operand) do
    {:continue, Map.put(state, :register_c, _dv(state, combo_operand))}
  end

  defp exec_bdv(state, combo_operand) do
    {:continue, Map.put(state, :register_b, _dv(state, combo_operand))}
  end

  defp _dv(state, combo_operand) do
    operand = combo_operator_value(state, combo_operand)

    state.register_a
    |> div(Integer.pow(2, operand))
    |> floor()
  end

  defp combo_operator_value(_state, value) when value <= 3, do: value

  defp combo_operator_value(state, 4), do: state.register_a

  defp combo_operator_value(state, 5), do: state.register_b

  defp combo_operator_value(state, 6), do: state.register_c

  defp parse(input) do
    state = %{
      register_a: 0,
      register_b: 0,
      register_c: 0,
      program: [],
      program_counter: 0,
      output: []
    }

    input
    |> break_into_rows()
    |> Enum.reduce(
      state,
      fn
        "Register A: " <> value, state ->
          Map.put(state, :register_a, String.to_integer(value))

        "Register B: " <> value, state ->
          Map.put(state, :register_b, String.to_integer(value))

        "Register C: " <> value, state ->
          Map.put(state, :register_c, String.to_integer(value))

        "Program: " <> value, state ->
          Map.put(state, :program, value |> String.split(",") |> Enum.map(&String.to_integer/1))

        _, state ->
          state
      end
    )
  end
end
