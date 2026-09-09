local tour = require("agent-tours.tour")

local function fixture(count, cursor)
  local steps = {}
  for i = 1, count do
    table.insert(steps, { path = "a.lua", range = { i, i }, note = "step " .. i })
  end
  return { version = 1, id = "t", root = "/r", cursor = cursor, steps = steps }
end

T.test("tour: load starts at the on-disk cursor", function()
  tour.load(fixture(5, 2))
  T.eq(tour.index(), 2)
  T.eq(tour.current().note, "step 3")
  T.eq(tour.count(), 5)
end)

T.test("tour: a missing or out-of-band cursor is clamped, not an error", function()
  tour.load(fixture(3, nil))
  T.eq(tour.index(), 0)
  tour.load(fixture(3, 99))
  T.eq(tour.index(), 2)
  tour.load(fixture(3, -4))
  T.eq(tour.index(), 0)
end)

T.test("tour: prev at step 0 does not move and reports it", function()
  tour.load(fixture(3, 0))
  T.eq(tour.prev(), false)
  T.eq(tour.index(), 0)
  T.ok(tour.at_start())
end)

T.test("tour: next at the last step does not move and reports it", function()
  tour.load(fixture(3, 2))
  T.eq(tour.next(), false)
  T.eq(tour.index(), 2)
  T.ok(tour.at_end())
end)

T.test("tour: next and prev walk the whole tour", function()
  tour.load(fixture(4, 0))
  local seen = { tour.current().note }
  while tour.next() do table.insert(seen, tour.current().note) end
  T.eq(seen, { "step 1", "step 2", "step 3", "step 4" })
  while tour.prev() do end
  T.eq(tour.index(), 0)
end)

T.test("tour: jump clamps and reports whether it moved", function()
  tour.load(fixture(4, 1))
  T.eq(tour.jump(1), false)
  T.eq(tour.jump(3), true)
  T.eq(tour.jump(50), false)
  T.eq(tour.index(), 3)
  T.eq(tour.jump(-50), true)
  T.eq(tour.index(), 0)
end)

T.test("tour: a single-step tour is at both ends at once", function()
  tour.load(fixture(1, 0))
  T.ok(tour.at_start())
  T.ok(tour.at_end())
  T.eq(tour.next(), false)
  T.eq(tour.prev(), false)
end)

T.test("tour: unload leaves nothing active", function()
  tour.load(fixture(3, 0))
  tour.unload()
  T.eq(tour.is_active(), false)
  T.eq(tour.count(), 0)
  T.eq(tour.current(), nil)
  T.eq(tour.next(), false)
end)
