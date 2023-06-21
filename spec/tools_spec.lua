describe("tools (general functionality toolkit)", function()
    local tools = require("tools")

    describe("merge_tables", function()
	it("merges two tables", function()
	    local t1 = {a = 1}
	    local t2 = {b = 2}

	    assert.same(tools.merge_tables(t1, t2), {a = 1, b = 2})
	end)

	it("does not change original tables", function()
	    local t1 = {a = 1}
	    local t2 = {b = 2}

	    local t1_unchanged = {a = 1}
	    local t2_unchanged = {b = 2}

	    tools.merge_tables(t1, t2)

	    assert.same(t1, t1_unchanged)
	    assert.same(t2, t2_unchanged)
	end)

	it("handles collisions by prefering the values in second table", function()
	    local t1 = {a = 1, b = 2, c = 3}
	    local t2 = {b = 1, c = 1}

	    assert.same(tools.merge_tables(t1, t2), {a = 1, b = 1, c = 1})
	end)
    end)
end)
