-- Only cosmetic external libraries
local log = require("lib.log")  -- For timestamps in logs
local inspect = require("lib.inspect")  -- For table displaying
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
    log.debug("assembly_line == " .. inspect(line.line:render()))

    line:run_mechanisms()
    line:push_line()
end

