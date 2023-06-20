local log = require("lib.log")  -- cosmetic library, primarily for timestamped logs
local async = require("async")


local imitate_random_errors = function()
    assert(math.random() >= 0.05, "Random panic")

    if math.random() < 0.05 then
	async.sleep(60)
    end
end


return {
    line = {},  -- TODO implement a structure for min shifting+indexing time
    mechanisms = {
	function(x)
	    async.sleep(1)  -- imitates waiting for the mechanism to finish working
	    imitate_random_errors()
	    return x * x  -- `^` would convert to a float
	end,

	function(x)
	    async.sleep(2)
	    imitate_random_errors()
	    return x - 1
	end,

	function(x)
	    async.sleep(1.5)
	    imitate_random_errors()
	    return x % 24
	end,
    },

    push_line = function(self)
	log.info("Pushing the line")

	local new_line = {}
	for position, value in pairs(self.line) do
	    new_line[position + 1] = value
	end

	self.line = new_line
    end,

    run_mechanisms = function(self)
	log.info("Starting mechanisms")

	-- Prep mechanisms with common logic
	local coroutines = {}
	for position, mechanism in pairs(self.mechanisms) do
	    coroutines[position] = function()
		if self.line[position] == nil then return end

		local result = mechanism(self.line[position])

		self.line[position] = result
		log.info("Mechanism #" .. position .. " finished with result " .. result)
	    end
	end

	async.run_multiple(coroutines, 10, function(position, message)
	    log.error("Mechanism #" .. position .. " finished with error '" .. message .. "'")
	end)

	log.info("All the mechanisms have stopped")
    end
}

