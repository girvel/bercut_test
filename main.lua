-- Questions for the dev team --
--
-- 1. Code style guidelines
--   1.1. Policy about explicit braces with single-argument atomic call
--   1.2. Indentation
--   1.3. Case
--   1.4. (!) Line width
-- 2. Should I use OOP-style state+behaviour or functional-style stateless functions+arguments?
-- 3. (?) Version of lua and usage of JIT
-- 4. (?) Should I implement constructors/finalizers, input/output holders for the assembly line or is it a single 
-- object?


-- Dev notes for myself --
--
-- -. Make mechanisms asynchronous
-- 2. README + github
-- -. Async waits
-- 4. Cover with docstrings
-- 5. Will a bunch of coroutines+asleep+cycle eat CPU? Consider a delay? Run benchmarks?
-- 6. Array with O(1) index shift


-- Implementation notes for the review --
--
-- I chose asynchronous architecture, because I've assumed that the mechanisms are external remote devices and you 
-- need to wait for them to finish execution. If they are just a code abstraction and a part of the same program, I 
-- would have consider using threading.


-- Only visual external libraries
local log = require("lib.log")  -- For timestamps in logs
local inspect = require("lib.inspect")  -- For displaying arrays with nils in the middle


-- Asynchronous toolkit --

local asleep = function(seconds)
  local endTime = os.time() + seconds
  while os.time() < endTime do
    coroutine.yield()
  end
end


-- API --

local assembly_line = {
    line = {},  -- TODO research better data structures for min shifting+indexing time
    mechanisms = {
	function(x)
	    -- imitates waiting for the mechanism to finish working and returning some result
	    asleep(1)
	    return x * x  -- ^ would convert to a float
	end,

	function(x)
	    asleep(2)

	    -- Randomly causes panic from time to time
	    assert(math.random() >= 0.1, "Random error")

	    return x - 1
	end,

	function(x)
	    asleep(1.5)
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

	-- Create coroutines
	local coroutines = {}
	for position, mechanism in pairs(self.mechanisms) do
	    if self.line[position] ~= nil then
		coroutines[position] = coroutine.create(mechanism)
	    end
	end

	-- Run created coroutines simultaneously
	while true do
	    local counter = 0
	    local ended_coroutines = {}

	    -- Go over all the coroutines to run them simultaneously
	    for position, current_coroutine in pairs(coroutines) do
	    	counter = counter + 1

		local success, result = coroutine.resume(current_coroutine, self.line[position])
		-- TODO handle errors (2 kinds)

		if not success then
		    -- TODO extract function async.gather(coroutines, delay, error_handler)
		    log.error("Error in mechanism #" .. position .. ": " .. result)
		    table.insert(ended_coroutines, position)
		    -- TODO manually handle errors

		elseif result ~= nil then
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

local next_number = 1000000
while true do
    assembly_line.line[1] = next_number
    next_number = next_number + 1
    log.debug("assembly_line == " .. inspect(assembly_line.line))

    assembly_line:run_mechanisms()
    assembly_line:push_line()
end

