insulate("assembly line", function()
    local assembly_line = require("assembly_line")

    describe("push_line", function()
	it("shifts the line 1 step forward", function()
	    local current_line = assembly_line(function() end, function() end, "warn")

	    current_line.line[1] = 1
	    current_line.line[2] = 2
	    current_line.line[3] = 3
	    current_line:push_line()

	    assert.same(current_line.line:render(), {nil, 1, 2, 3})
	end)
    end)

    describe("run_mechanisms", function()
	it("applies a specific action to first 3 elements of the line", function()
	    local current_line = assembly_line(function() end, function() end, "warn")

	    current_line.line[1] = 25
	    current_line.line[2] = 26
	    current_line.line[3] = 27

	    current_line:run_mechanisms()

	    assert.same(current_line.line:render(), {625, 25, 3})
	end)

	it("runs mechanisms simultaneously", function()
	    local current_line = assembly_line(function() end, function() end, "warn")

	    local t = os.clock()
	    current_line.line = {25, 26, 27}
	    current_line:run_mechanisms()
	    t = os.clock() - t

	    assert.is_true(t >= 2)
	    assert.is_true(t < 2.5)
	end)
    end)
end)
