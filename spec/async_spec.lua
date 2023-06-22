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

	    assert.is_true(t >= 1)
	    assert.is_true(t < 2.5)

	    assert.same(finished_functions, {f1 = true, f2 = true})
	end)

	it("can abort function that exceed timeout", function()
	    local finished_functions = {}

	    local f1 = function()
		async.sleep(1)
		finished_functions["f1"] = true
	    end

	    local f2 = function()
		async.sleep(10)
		finished_functions["f2"] = true
	    end

	    local t = os.clock()
	    async.run_multiple({f1, f2}, 2)
	    t = os.clock() - t

	    assert.is_true(t >= 2)
	    assert.is_true(t < 2.5)

	    assert.same(finished_functions, {f1 = true})
	end)

	it("can handle errors", function()
	    local finished_functions = {}
	    local failed = false

	    local f1 = function()
		async.sleep(1)
		finished_functions["f1"] = true
	    end

	    local f2 = function()
		async.sleep(2)
		error()
		finished_functions["f2"] = true
	    end

	    local t = os.clock()
	    async.run_multiple({f1, f2}, 3, function()
		failed = true
	    end)
	    t = os.clock() - t

	    assert.is_true(t >= 2)
	    assert.is_true(t < 2.5)

	    assert.same(finished_functions, {f1 = true})
	    assert.same(failed, true)
	end)
    end)
end)
