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


local log = require("log")


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
	    return x ^ 2
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

	local coroutines = {}
	for position, mechanism in pairs(self.mechanisms) do
	    coroutines[position] = coroutine.create(mechanism)
	end

	-- Run created coroutines simultaneously
	while true do
	    local counter = 0
	    local ended_coroutines = {}

	    for position, current_coroutine in pairs(coroutines) do
	    	counter = counter + 1

		local _, result = coroutine.resume(current_coroutine, self.line[position])  -- TODO handle errors (2 kinds)

		if result ~= nil then
		    self.line[position] = result
		    table.insert(ended_coroutines, position)
		end
	    end

	    for _, position in ipairs(ended_coroutines) do
		coroutines[position] = nil
	    end

	    if counter == 0 then
	    	break
	    end
	end

	log.info("All the mechanisms have stopped")
    end
}


-- Demo script --

assembly_line.line = {6, 25}
log.debug("assembly_line == {" .. table.concat(assembly_line.line, ", ") .. "}")
assembly_line:run_mechanisms()
log.debug("assembly_line == {" .. table.concat(assembly_line.line, ", ") .. "}")
