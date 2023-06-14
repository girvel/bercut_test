-- Questions for the dev team --
--
-- 1. Code style guidelines
--   1.1. Policy about explicit braces with single-argument atomic call
--   1.2. Indentation
--   1.3. Case
--   1.4. (!) Line width
-- 2. Should I use OOP-style state+behaviour or functional-style stateless functions+arguments?
-- 3. (?) Version of lua and usage of JIT
-- 4. (?) Should I implement constructors/finalizers, input/output holders for the assembly line or is it a single object?


-- Dev notes for myself --
--
-- 1. Make mechanisms asynchronous
-- 2. README + github
-- 3. Async waits


-- Only visual external libraries
local log = require("log")  -- For timestamps in logs
local inspect = require("inspect")  -- For displaying arrays with nils in the middle


-- Asynchronous toolkit --

local asleep = function(seconds)
  local endTime = os.time() + seconds
  while os.time() < endTime do
    coroutine.yield()
  end
end


-- API --

local assembly_line = {
    line = {},  -- research better data structures for min shifting+indexing time
    mechanisms = {
	function(x)
	    asleep(1)
	    return x * x  -- ^ would convert to a float
	end,

	function(x)
	    asleep(2)
	    return x - 1
	end,
    },

    push_line = function(self)
	log.info("Pushing the line")
    end,

    run_mechanisms = function(self)
	log.info("Starting mechanisms")

	-- Create coroutines
	local coroutines = {}
	for position, mechanism in pairs(self.mechanisms) do
	    coroutines[position] = coroutine.create(mechanism)
	end

	-- Run created coroutines simultaneously
	while true do
	    local counter = 0
	    local ended_coroutines = {}

	    -- Go over all the coroutines to run them simultaneously
	    for position, current_coroutine in pairs(coroutines) do
	    	counter = counter + 1

		local _, result = coroutine.resume(current_coroutine, self.line[position])  -- TODO handle errors (2 kinds)

		if result ~= nil then
		    self.line[position] = result
		    table.insert(ended_coroutines, position)
		end
	    end

	    -- Remove all ended coroutines
	    for _, position in ipairs(ended_coroutines) do
		coroutines[position] = nil
		log.info("Mechanism #" .. position .. " finished")
	    end

	    -- Stop if execution has ended
	    if counter == 0 then
	    	break
	    end
	end

	log.info("All the mechanisms have stopped")
    end
}


-- Demo script --

assembly_line.line = {6, 25}
log.debug("assembly_line == " .. inspect(assembly_line.line))
assembly_line:run_mechanisms()
log.debug("assembly_line == " .. inspect(assembly_line.line))
