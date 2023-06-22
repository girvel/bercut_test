local log = require("lib.log")  -- cosmetic library, primarily for timestamped logs
local async = require("async")
local tools = require("tools")
local shifting_array = require("shifting_array")


--- Create new assembly line
-- @param imitate_random_errors Function to raise errors randomly
-- @param error_handler Function handling errors; receives table with current environment
-- @param log_level String representing minimal level of displayed log messages; see lib.log
return function(imitate_random_errors, error_handler, log_level)
    log.level = log_level or "trace"

    return {
	--- Line itself representing an infinite assembly line with the table of numbers
	line = shifting_array(),

	--- Functions, representing the launch of each mechanism
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

	--- Push the line 1 step forward
	push_line = function(self)
	    log.info("Pushing the line")
	    self.line:shift()
	end,

	--- Launch all mechanisms asynchronously
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
		error_handler(tools.merge_tables(_ENV, {self = self, position = position, message = message}))
	    end)

	    log.info("All the mechanisms have stopped")
	end
    }
end

