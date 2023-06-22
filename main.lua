-- Dev notes for myself --
--
-- xx. Make mechanisms asynchronous
-- 02. README + github
-- xx. Async waits
-- 04. Cover with docstrings
-- xx. Will a bunch of coroutines+asleep+cycle eat CPU? Consider a delay? Run benchmarks?
-- 06. Array with O(1) index shift
-- xx. OS-based blocking sleep -> use it as delay in async.sleep for optimization purposes
-- xx. Consider that coroutine.yield() in async.sleep potentially takes some time
-- xx. Lua shell for fixing issues
-- 10. Cover w/ tests + testing infoblock in README
-- xx. Bug: coroutine timeout when using shell


-- Implementation notes for the review --
--
-- I chose asynchronous architecture, because I have assumed that the mechanisms are external remote devices and you 
-- need to wait for them to finish execution. If they are just a code abstraction and a part of the same program, I 
-- would have consider using threading.
--
-- Also there is no advanced async/await in pure Lua, so I wrote a minimalistic module `async` to implement some basic
-- constructions.


-- Only cosmetic external libraries
local log = require("lib.log")  -- For timestamps in logs
local assembly_line = require("assembly_line")
local shell = require("shell")
local async = require("async")


local imitate_random_errors = function()
    assert(math.random() >= 0.05, "Random panic")

    if math.random() < 0.05 then
	async.sleep(60)
    end
end

log.info("Creating assembly line")
local line = assembly_line(imitate_random_errors, shell)

log.info("Assembly line script starts")
math.randomseed(os.time())

local current_number = 1000000
while true do
    line.line[1] = current_number
    current_number = current_number + 1
    log.debug("assembly_line == " .. table.concat(line.line, ', '))

    line:run_mechanisms()
    line:push_line()
end

