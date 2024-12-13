defmodule AdventOfCode.Day13 do
  import AdventOfCode.Utils

  @button_a_regex ~r/Button A: X\+(\d+), Y\+(\d+)/
  @button_b_regex ~r/Button B: X\+(\d+), Y\+(\d+)/
  @prize_regex ~r/Prize: X=(\d+), Y=(\d+)/

  # --- Day 13: Claw Contraption ---
  #
  # Next up: the lobby of a resort on a tropical island. The Historians take a moment to admire the hexagonal floor tiles before spreading out.
  #
  # Fortunately, it looks like the resort has a new arcade! Maybe you can win some prizes from the claw machines?
  #
  # The claw machines here are a little unusual. Instead of a joystick or directional buttons to control the claw, these machines have two buttons labeled A and B. Worse, you can't just put in a token and play; it costs 3 tokens to push the A button and 1 token to push the B button.
  #
  # With a little experimentation, you figure out that each machine's buttons are configured to move the claw a specific amount to the right (along the X axis) and a specific amount forward (along the Y axis) each time that button is pressed.
  #
  # Each machine contains one prize; to win the prize, the claw must be positioned exactly above the prize on both the X and Y axes.
  #
  # You wonder: what is the smallest number of tokens you would have to spend to win as many prizes as possible? You assemble a list of every machine's button behavior and prize location (your puzzle input). For example:
  #
  # Button A: X+94, Y+34
  # Button B: X+22, Y+67
  # Prize: X=8400, Y=5400
  #
  # Button A: X+26, Y+66
  # Button B: X+67, Y+21
  # Prize: X=12748, Y=12176
  #
  # Button A: X+17, Y+86
  # Button B: X+84, Y+37
  # Prize: X=7870, Y=6450
  #
  # Button A: X+69, Y+23
  # Button B: X+27, Y+71
  # Prize: X=18641, Y=10279
  #
  # This list describes the button configuration and prize location of four different claw machines.
  #
  # For now, consider just the first claw machine in the list:
  #
  #     Pushing the machine's A button would move the claw 94 units along the X axis and 34 units along the Y axis.
  #     Pushing the B button would move the claw 22 units along the X axis and 67 units along the Y axis.
  #     The prize is located at X=8400, Y=5400; this means that from the claw's initial position, it would need to move exactly 8400 units along the X axis and exactly 5400 units along the Y axis to be perfectly aligned with the prize in this machine.
  #
  # The cheapest way to win the prize is by pushing the A button 80 times and the B button 40 times. This would line up the claw along the X axis (because 80*94 + 40*22 = 8400) and along the Y axis (because 80*34 + 40*67 = 5400). Doing this would cost 80*3 tokens for the A presses and 40*1 for the B presses, a total of 280 tokens.
  #
  # For the second and fourth claw machines, there is no combination of A and B presses that will ever win a prize.
  #
  # For the third claw machine, the cheapest way to win the prize is by pushing the A button 38 times and the B button 86 times. Doing this would cost a total of 200 tokens.
  #
  # So, the most prizes you could possibly win is two; the minimum tokens you would have to spend to win all (two) prizes is 480.
  #
  # You estimate that each button would need to be pressed no more than 100 times to win a prize. How else would someone be expected to play?
  #
  # Figure out how to win as many prizes as possible. What is the fewest tokens you would have to spend to win all possible prizes?
  #
  # Your puzzle answer was 25629.
  # --- Part Two ---
  #
  # As you go to win the first prize, you discover that the claw is nowhere near where you expected it would be. Due to a unit conversion error in your measurements, the position of every prize is actually 10000000000000 higher on both the X and Y axis!
  #
  # Add 10000000000000 to the X and Y position of every prize. After making this change, the example above would now look like this:
  #
  # Button A: X+94, Y+34
  # Button B: X+22, Y+67
  # Prize: X=10000000008400, Y=10000000005400
  #
  # Button A: X+26, Y+66
  # Button B: X+67, Y+21
  # Prize: X=10000000012748, Y=10000000012176
  #
  # Button A: X+17, Y+86
  # Button B: X+84, Y+37
  # Prize: X=10000000007870, Y=10000000006450
  #
  # Button A: X+69, Y+23
  # Button B: X+27, Y+71
  # Prize: X=10000000018641, Y=10000000010279
  #
  # Now, it is only possible to win a prize on the second and fourth claw machines. Unfortunately, it will take many more than 100 presses to do so.
  #
  # Using the corrected prize coordinates, figure out how to win as many prizes as possible. What is the fewest tokens you would have to spend to win all possible prizes?
  #
  # Your puzzle answer was 107487112929999.

  def find_fewest_number_of_tokens_needed_to_win_all_prizes(input, offset) do
    input
    |> parse()
    |> find_cheapest_solutions(offset)
  end

  defp find_cheapest_solutions(machines, offset) do
    machines
    |> Enum.map(&find_cheapest_solution(&1, offset))
    |> Enum.reject(&is_nil/1)
    |> sum()
  end

  # So this is a simple math problem. We have 2 equations with 2 unknowns:
  #   Ax * X + Bx * Y = Px
  #   Ay * X + By * Y = Py
  #
  # And we have to find X and Y where X is the number of times we need to
  # press the A button and Y is the number of times we need to press the B.
  #
  # So if we restate the second equation in terms of X we get:
  #   X = (Py - By * Y) / Ay
  #
  # If we then substitute this into the first equation we get and express it
  # in terms of Y we get:
  #   Y = (Px * Ay - Py * Ax) / (Ay * Bx - Ax * By)
  #
  # Since we are working with button presses we have to reject any negative
  # solutions - you can't press a button -3 times - and any non-integer
  # solutions - you can't press a button 2.467 times.
  #
  # So the 100 button presses thing is a complete red herring.
  defp find_cheapest_solution(machine, offset) do
    {ax, ay} = machine.button_a
    {bx, by} = machine.button_b
    {px, py} = machine.prize

    px = px + offset
    py = py + offset

    y = (px * ay - py * ax) / (ay * bx - ax * by)
    x = (py - by * y) / ay

    # Convert floats to integers
    roundedx = round(x)
    roundedy = round(y)

    if x >= 0 && y >= 0 && roundedx == x && roundedy == y do
      roundedx * 3 + roundedy
    else
      nil
    end
  end

  defp parse(input) do
    {machines, current_machine} =
      input
      |> String.split("\n")
      |> Enum.map(&String.trim(&1))
      |> Enum.reduce({[], %{}}, fn line, {machines, current_machine} ->
        cond do
          "" == line ->
            {[current_machine | machines], %{}}

          String.match?(line, @button_a_regex) ->
            [[_, x, y]] = Regex.scan(@button_a_regex, line)
            x = String.to_integer(x)
            y = String.to_integer(y)
            current_machine = Map.put(current_machine, :button_a, {x, y})
            {machines, current_machine}

          String.match?(line, @button_b_regex) ->
            [[_, x, y]] = Regex.scan(@button_b_regex, line)
            x = String.to_integer(x)
            y = String.to_integer(y)
            current_machine = Map.put(current_machine, :button_b, {x, y})
            {machines, current_machine}

          String.match?(line, @prize_regex) ->
            [[_, x, y]] = Regex.scan(@prize_regex, line)
            x = String.to_integer(x)
            y = String.to_integer(y)
            current_machine = Map.put(current_machine, :prize, {x, y})
            {machines, current_machine}

          true ->
            raise "Invalid input line: #{inspect(line)}"
        end
      end)

    [current_machine | machines]
    |> Enum.filter(fn
      %{prize: _, button_a: _, button_b: _} -> true
      _ -> false
    end)
    |> Enum.reverse()
  end
end
