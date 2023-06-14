-- Questions for the dev team --
--
-- 1. Code style guidelines
--   1.1. Policy about explicit braces with single-argument atomic call
--   1.2. Indentation
--   1.3. Case
--   1.4. (!) Line width
-- 2. Should I use OOP-style state+behaviour or functional-style stateless functions+arguments?
-- 3. (?) Version of lua and usage of JIT
-- 4. (?) Should I implement constructors/finalizers for the assembly line or is it a single object?


-- Dev notes for myself --
--
-- 1. Make mechanisms asynchronous


local log = require("log")


-- API --

local assembly_line = {
    push_line = function()
	log.info("Pushing the line")
    end
}


-- Demo script --

assembly_line.push_line()

