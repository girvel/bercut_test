describe("async (Basic async-await -like functionality)", function()
    local async = require("async")

    describe("sleep + run_multiple", function()
	it("can run multiple functions with waiting for something simultaneously", function()
	    local finished_functions = {}

	    local f1 = function()
		async.sleep(1)
		finished_functions["f1"] = true
	    end

	    local f2 = function()
		async.sleep(2)
		finished_functions["f2"] = true
	    end

	    local t = os.clock()
	    async.run_multiple({f1, f2})
	    t = os.clock() - t

	    print(t)
	    assert.is_true(t >= 1)
	    assert.is_true(t < 2.5)

	    assert.same(finished_functions, {f1 = true, f2 = true})
	end)
    end)
end)
