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
local inspect = require("lib.inspect")  -- Substantially more informative than table.concat
local assembly_line = require("assembly_line")


log.info("Assembly line script starts")
math.randomseed(os.time())

local current_number = 1000000
while true do
    assembly_line.line[1] = current_number
    current_number = current_number + 1
    log.debug("assembly_line == " .. inspect(assembly_line.line))

    assembly_line:run_mechanisms()
    assembly_line:push_line()
end

