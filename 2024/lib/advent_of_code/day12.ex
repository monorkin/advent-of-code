defmodule AdventOfCode.Day12 do
  import AdventOfCode.Utils

  # --- Day 12: Garden Groups ---
  #
  # Why not search for the Chief Historian near the gardener and his massive farm? There's plenty of food, so The Historians grab something to eat while they search.
  #
  # You're about to settle near a complex arrangement of garden plots when some Elves ask if you can lend a hand. They'd like to set up fences around each region of garden plots, but they can't figure out how much fence they need to order or how much it will cost. They hand you a map (your puzzle input) of the garden plots.
  #
  # Each garden plot grows only a single type of plant and is indicated by a single letter on your map. When multiple garden plots are growing the same type of plant and are touching (horizontally or vertically), they form a region. For example:
  #
  # AAAA
  # BBCD
  # BBCC
  # EEEC
  #
  # This 4x4 arrangement includes garden plots growing five different types of plants (labeled A, B, C, D, and E), each grouped into their own region.
  #
  # In order to accurately calculate the cost of the fence around a single region, you need to know that region's area and perimeter.
  #
  # The area of a region is simply the number of garden plots the region contains. The above map's type A, B, and C plants are each in a region of area 4. The type E plants are in a region of area 3; the type D plants are in a region of area 1.
  #
  # Each garden plot is a square and so has four sides. The perimeter of a region is the number of sides of garden plots in the region that do not touch another garden plot in the same region. The type A and C plants are each in a region with perimeter 10. The type B and E plants are each in a region with perimeter 8. The lone D plot forms its own region with perimeter 4.
  #
  # Visually indicating the sides of plots in each region that contribute to the perimeter using - and |, the above map's regions' perimeters are measured as follows:
  #
  # +-+-+-+-+
  # |A A A A|
  # +-+-+-+-+     +-+
  #               |D|
  # +-+-+   +-+   +-+
  # |B B|   |C|
  # +   +   + +-+
  # |B B|   |C C|
  # +-+-+   +-+ +
  #           |C|
  # +-+-+-+   +-+
  # |E E E|
  # +-+-+-+
  #
  # Plants of the same type can appear in multiple separate regions, and regions can even appear within other regions. For example:
  #
  # OOOOO
  # OXOXO
  # OOOOO
  # OXOXO
  # OOOOO
  #
  # The above map contains five regions, one containing all of the O garden plots, and the other four each containing a single X plot.
  #
  # The four X regions each have area 1 and perimeter 4. The region containing 21 type O plants is more complicated; in addition to its outer edge contributing a perimeter of 20, its boundary with each X region contributes an additional 4 to its perimeter, for a total perimeter of 36.
  #
  # Due to "modern" business practices, the price of fence required for a region is found by multiplying that region's area by its perimeter. The total price of fencing all regions on a map is found by adding together the price of fence for every region on the map.
  #
  # In the first example, region A has price 4 * 10 = 40, region B has price 4 * 8 = 32, region C has price 4 * 10 = 40, region D has price 1 * 4 = 4, and region E has price 3 * 8 = 24. So, the total price for the first example is 140.
  #
  # In the second example, the region with all of the O plants has price 21 * 36 = 756, and each of the four smaller X regions has price 1 * 4 = 4, for a total price of 772 (756 + 4 + 4 + 4 + 4).
  #
  # Here's a larger example:
  #
  # RRRRIICCFF
  # RRRRIICCCF
  # VVRRRCCFFF
  # VVRCCCJFFF
  # VVVVCJJCFE
  # VVIVCCJJEE
  # VVIIICJJEE
  # MIIIIIJJEE
  # MIIISIJEEE
  # MMMISSJEEE
  #
  # It contains:
  #
  #     A region of R plants with price 12 * 18 = 216.
  #     A region of I plants with price 4 * 8 = 32.
  #     A region of C plants with price 14 * 28 = 392.
  #     A region of F plants with price 10 * 18 = 180.
  #     A region of V plants with price 13 * 20 = 260.
  #     A region of J plants with price 11 * 20 = 220.
  #     A region of C plants with price 1 * 4 = 4.
  #     A region of E plants with price 13 * 18 = 234.
  #     A region of I plants with price 14 * 22 = 308.
  #     A region of M plants with price 5 * 12 = 60.
  #     A region of S plants with price 3 * 8 = 24.
  #
  # So, it has a total price of 1930.
  #
  # What is the total price of fencing all regions on your map?
  #
  # Your puzzle answer was 1431316.
  #
  # --- Part Two ---
  #
  # Fortunately, the Elves are trying to order so much fence that they qualify for a bulk discount!
  #
  # Under the bulk discount, instead of using the perimeter to calculate the price, you need to use the number of sides each region has. Each straight section of fence counts as a side, regardless of how long it is.
  #
  # Consider this example again:
  #
  # AAAA
  # BBCD
  # BBCC
  # EEEC
  #
  # The region containing type A plants has 4 sides, as does each of the regions containing plants of type B, D, and E. However, the more complex region containing the plants of type C has 8 sides!
  #
  # Using the new method of calculating the per-region price by multiplying the region's area by its number of sides, regions A through E have prices 16, 16, 32, 4, and 12, respectively, for a total price of 80.
  #
  # The second example above (full of type X and O plants) would have a total price of 436.
  #
  # Here's a map that includes an E-shaped region full of type E plants:
  #
  # EEEEE
  # EXXXX
  # EEEEE
  # EXXXX
  # EEEEE
  #
  # The E-shaped region has an area of 17 and 12 sides for a price of 204. Including the two regions full of type X plants, this map has a total price of 236.
  #
  # This map has a total price of 368:
  #
  # AAAAAA
  # AAABBA
  # AAABBA
  # ABBAAA
  # ABBAAA
  # AAAAAA
  #
  # It includes two regions full of type B plants (each with 4 sides) and a single region full of type A plants (with 4 sides on the outside and 8 more sides on the inside, a total of 12 sides). Be especially careful when counting the fence around regions like the one full of type A plants; in particular, each section of fence has an in-side and an out-side, so the fence does not connect across the middle of the region (where the two B regions touch diagonally). (The Elves would have used the Möbius Fencing Company instead, but their contract terms were too one-sided.)
  #
  # The larger example from before now has the following updated prices:
  #
  #     A region of R plants with price 12 * 10 = 120.
  #     A region of I plants with price 4 * 4 = 16.
  #     A region of C plants with price 14 * 22 = 308.
  #     A region of F plants with price 10 * 12 = 120.
  #     A region of V plants with price 13 * 10 = 130.
  #     A region of J plants with price 11 * 12 = 132.
  #     A region of C plants with price 1 * 4 = 4.
  #     A region of E plants with price 13 * 8 = 104.
  #     A region of I plants with price 14 * 16 = 224.
  #     A region of M plants with price 5 * 6 = 30.
  #     A region of S plants with price 3 * 6 = 18.
  #
  # Adding these together produces its new total price of 1206.
  #
  # What is the new total price of fencing all regions on your map?
  #
  # --- Part Two ---
  #
  # Fortunately, the Elves are trying to order so much fence that they qualify for a bulk discount!
  #
  # Under the bulk discount, instead of using the perimeter to calculate the price, you need to use the number of sides each region has. Each straight section of fence counts as a side, regardless of how long it is.
  #
  # Consider this example again:
  #
  # AAAA
  # BBCD
  # BBCC
  # EEEC
  #
  # The region containing type A plants has 4 sides, as does each of the regions containing plants of type B, D, and E. However, the more complex region containing the plants of type C has 8 sides!
  #
  # Using the new method of calculating the per-region price by multiplying the region's area by its number of sides, regions A through E have prices 16, 16, 32, 4, and 12, respectively, for a total price of 80.
  #
  # The second example above (full of type X and O plants) would have a total price of 436.
  #
  # Here's a map that includes an E-shaped region full of type E plants:
  #
  # EEEEE
  # EXXXX
  # EEEEE
  # EXXXX
  # EEEEE
  #
  # The E-shaped region has an area of 17 and 12 sides for a price of 204. Including the two regions full of type X plants, this map has a total price of 236.
  #
  # This map has a total price of 368:
  #
  # AAAAAA
  # AAABBA
  # AAABBA
  # ABBAAA
  # ABBAAA
  # AAAAAA
  #
  # It includes two regions full of type B plants (each with 4 sides) and a single region full of type A plants (with 4 sides on the outside and 8 more sides on the inside, a total of 12 sides). Be especially careful when counting the fence around regions like the one full of type A plants; in particular, each section of fence has an in-side and an out-side, so the fence does not connect across the middle of the region (where the two B regions touch diagonally). (The Elves would have used the Möbius Fencing Company instead, but their contract terms were too one-sided.)
  #
  # The larger example from before now has the following updated prices:
  #
  #     A region of R plants with price 12 * 10 = 120.
  #     A region of I plants with price 4 * 4 = 16.
  #     A region of C plants with price 14 * 22 = 308.
  #     A region of F plants with price 10 * 12 = 120.
  #     A region of V plants with price 13 * 10 = 130.
  #     A region of J plants with price 11 * 12 = 132.
  #     A region of C plants with price 1 * 4 = 4.
  #     A region of E plants with price 13 * 8 = 104.
  #     A region of I plants with price 14 * 16 = 224.
  #     A region of M plants with price 5 * 6 = 30.
  #     A region of S plants with price 3 * 6 = 18.
  #
  # Adding these together produces its new total price of 1206.
  #
  # What is the new total price of fencing all regions on your map?
  #
  # Your puzzle answer was 821428.

  def calculate_total_fencing_price(input, apply_bulk_discount) do
    input
    |> parse_grid()
    |> init()
    |> create_regions()
    |> calculate_area()
    |> calculate_perimiter()
    |> calculate_sides()
    |> calculate_price(apply_bulk_discount)
  end

  defp calculate_sides({map, meta}) do
    sides =
      meta.regions
      |> Enum.reduce(%{}, fn {region, coords}, acc ->
        map =
          Enum.reduce(coords, %{}, fn coord, map ->
            Map.put(map, coord, :occupied)
          end)

        coords
        |> Enum.sort_by(fn {x, y} -> {y, x} end)
        |> Enum.reduce({acc, map, 0}, fn {x, y}, {acc, map, next_id} ->
          north_coord = {x, y - 1}
          north = Map.get(map, north_coord, %{})

          east_coord = {x + 1, y}
          east = Map.get(map, east_coord, %{})

          south_coord = {x, y + 1}
          south = Map.get(map, south_coord, %{})

          west_coord = {x - 1, y}
          west = Map.get(map, west_coord, %{})

          {map, next_id} = assign_side(map, north_coord, north, :south, next_id)
          {map, next_id} = assign_side(map, east_coord, east, :west, next_id)
          {map, next_id} = assign_side(map, south_coord, south, :north, next_id)
          {map, next_id} = assign_side(map, west_coord, west, :east, next_id)

          {Map.put(acc, region, next_id), map, next_id}
        end)
        |> elem(0)
      end)

    {map, Map.put(meta, :sides, sides)}
  end

  defp assign_side(map, _coord, :occupied, _side, next_id), do: {map, next_id}

  defp assign_side(map, {x, y} = coord, assigns, side, next_id) do
    assigns = assigns || %{north: nil, east: nil, south: nil, west: nil}

    neighbour_coords =
      case side do
        :north -> [{x - 1, y}, {x + 1, y}]
        :south -> [{x - 1, y}, {x + 1, y}]
        :east -> [{x, y - 1}, {x, y + 1}]
        :west -> [{x, y - 1}, {x, y + 1}]
      end

    neighbout_id =
      neighbour_coords
      |> Enum.reduce(nil, fn coord, acc ->
        if acc do
          acc
        else
          Map.get(map, coord, nil)
          |> case do
            nas when is_map(nas) -> Map.get(nas, side, nil)
            _ -> nil
          end
        end
      end)

    if neighbout_id do
      assigns = Map.put(assigns, side, neighbout_id)
      {Map.put(map, coord, assigns), next_id}
    else
      assigns = Map.put(assigns, side, next_id)
      {Map.put(map, coord, assigns), next_id + 1}
    end
  end

  defp calculate_price({_map, meta}, apply_bulk_discount) do
    Enum.reduce(meta.area, 0, fn {k, area}, acc ->
      map = if apply_bulk_discount, do: meta.sides, else: meta.perimiter
      perimiter = Map.get(map, k, 0)

      acc + perimiter * area
    end)
  end

  defp calculate_perimiter({map, meta}) do
    regions = meta.region_coords

    perimiter =
      meta.regions
      |> Enum.reduce(%{}, fn {id, cells}, acc ->
        Enum.reduce(cells, acc, fn {x, y}, acc ->
          perimiter = Map.get(acc, id, 0)
          north = {x, y - 1}
          perimiter = if Map.get(regions, north, nil) != id, do: perimiter + 1, else: perimiter

          south = {x, y + 1}
          perimiter = if Map.get(regions, south, nil) != id, do: perimiter + 1, else: perimiter

          west = {x - 1, y}
          perimiter = if Map.get(regions, west, nil) != id, do: perimiter + 1, else: perimiter

          east = {x + 1, y}
          perimiter = if Map.get(regions, east, nil) != id, do: perimiter + 1, else: perimiter

          Map.put(acc, id, perimiter)
        end)
      end)

    {map, Map.put(meta, :perimiter, perimiter)}
  end

  defp calculate_area({map, meta}) do
    area =
      meta.regions
      |> Enum.reduce(%{}, fn {k, v}, acc ->
        Map.put(acc, k, length(v))
      end)

    {map, Map.put(meta, :area, area)}
  end

  defp create_regions({map, meta}) do
    region_coords =
      map
      |> Enum.map(& &1)
      |> Enum.sort_by(fn {{x, y}, _} -> {y, x} end)
      |> Enum.reduce({%{}, 0}, fn {{x, y}, type}, {regions, next_id} ->
        id = neighbouring_region_id(map, regions, {x, y}, type)

        {id, regions} =
          if is_nil(id) do
            {next_id, flood_fill(map, regions, {x, y}, type, next_id)}
          else
            {id, regions}
          end

        next_id = if id == next_id, do: next_id + 1, else: next_id

        regions = Map.put(regions, {x, y}, id)

        {regions, next_id}
      end)
      |> elem(0)

    regions =
      region_coords
      |> Enum.group_by(fn {_, id} -> id end)
      |> Enum.reduce(%{}, fn {id, coords}, acc ->
        Enum.reduce(coords, acc, fn {coord, _}, acc ->
          Map.update(acc, id, [coord], &[coord | &1])
        end)
      end)

    meta =
      meta
      |> Map.put(:regions, regions)
      |> Map.put(:region_coords, region_coords)

    {map, meta}
  end

  defp neighbouring_region_id(map, regions, {x, y}, type) do
    north = {x, y - 1}
    north_type = Map.get(map, north, nil)
    north_id = Map.get(regions, north, nil)

    south = {x, y + 1}
    south_type = Map.get(map, south, nil)
    south_id = Map.get(regions, south, nil)

    west = {x - 1, y}
    west_type = Map.get(map, west, nil)
    west_id = Map.get(regions, west, nil)

    east = {x + 1, y}
    east_type = Map.get(map, east, nil)
    east_id = Map.get(regions, east, nil)

    cond do
      north_type == type and not is_nil(north_id) ->
        north_id

      west_type == type and not is_nil(west_id) ->
        west_id

      east_type == type and not is_nil(east_id) ->
        east_id

      south_type == type and not is_nil(south_id) ->
        south_id

      true ->
        nil
    end
  end

  defp flood_fill(map, regions, {x, y}, type, next_id) do
    regions = Map.put(regions, {x, y}, next_id)

    north = {x, y - 1}
    north_type = Map.get(map, north, nil)
    north_id = Map.get(regions, north, nil)

    regions =
      if north_type == type and is_nil(north_id) do
        flood_fill(map, regions, north, type, next_id)
      else
        regions
      end

    east = {x + 1, y}
    east_type = Map.get(map, east, nil)
    east_id = Map.get(regions, east, nil)

    regions =
      if east_type == type and is_nil(east_id) do
        flood_fill(map, regions, east, type, next_id)
      else
        regions
      end

    south = {x, y + 1}
    south_type = Map.get(map, south, nil)
    south_id = Map.get(regions, south, nil)

    regions =
      if south_type == type and is_nil(south_id) do
        flood_fill(map, regions, south, type, next_id)
      else
        regions
      end

    west = {x - 1, y}
    west_type = Map.get(map, west, nil)
    west_id = Map.get(regions, west, nil)

    regions =
      if west_type == type and is_nil(west_id) do
        flood_fill(map, regions, west, type, next_id)
      else
        regions
      end

    regions
  end

  defp init(map) do
    {map, %{}}
  end
end
