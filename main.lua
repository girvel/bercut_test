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


-- Only cosmetic external libraries
local log = require("lib.log")  -- For timestamps in logs
local inspect = require("lib.inspect")  -- For displaying arrays with nils in the middle


-- Asynchronous toolkit --

local async = {
    sleep = function(seconds)
	-- consumes CPU, potentially needs blocking sleep function from external library function or OS-dependent
	-- utilities such as Linux `sleep`

	local endTime = os.time() + seconds
	while os.time() < endTime do
	    coroutine.yield()
	end
    end,

    run_multiple = function(functions, timeout, error_handler)
	-- Create coroutines
	local coroutines = {}
	for position, f in pairs(functions) do
	    coroutines[position] = coroutine.create(f)
	end

	-- Run created coroutines simultaneously
	while true do
	    local counter = 0
	    local ended_coroutines = {}

	    for position, current_coroutine in pairs(coroutines) do
	    	counter = counter + 1

		local success, result = coroutine.resume(current_coroutine, position)
		-- TODO handle timeout

		if coroutine.status(current_coroutine) == "dead" then
		    table.insert(ended_coroutines, position)

		    if not success then
			error_handler(position, result)
		    end
		end
	    end

	    -- Remove all ended coroutines
	    for _, position in ipairs(ended_coroutines) do
		coroutines[position] = nil
	    end

	    -- Stop if there are no coroutines remaining
	    if counter == 0 then
	    	break
	    end
	end
    end,
}


-- API --

local assembly_line = {
    line = {},  -- TODO implement a structure for min shifting+indexing time
    mechanisms = {
	function(x)
	    -- imitates waiting for the mechanism to finish working and returning some result
	    async.sleep(1)
	    return x * x  -- `^` would convert to a float
	end,

	function(x)
	    async.sleep(2)

	    -- Randomly causes panic from time to time
	    assert(math.random() >= 0.1, "Random error")

	    return x - 1
	end,

	function(x)
	    async.sleep(1.5)
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
		log.debug(position)

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


-- Demo script --

math.randomseed(os.time())

local current_number = 1000000
while true do
    assembly_line.line[1] = current_number
    current_number = current_number + 1
    log.debug("assembly_line == " .. inspect(assembly_line.line))

    assembly_line:run_mechanisms()
    assembly_line:push_line()
end

