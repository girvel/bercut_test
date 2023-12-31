local inspect = require("lib.inspect")
local tools = require("tools")


--- Launches Lua shell
-- @param env Lua environment for the shell to be run in.
return function(env)
    env = env or {}

    local line_counter = 1
    local exit_signal = {}
    local exit = function() return exit_signal end

    print(_VERSION .. " shell; use exit() to exit")

    while true do
	io.write("\t" .. line_counter .. ": ")

	local line_of_code = io.read()
	local args = {"shell:" .. line_counter, "t", tools.merge_tables(env, {exit = exit})}

	-- Try to evaluate as expression
	local f, error_ = load("return " .. line_of_code, table.unpack(args))

	-- Or try to evaluate as a statement
	if f == nil then
	    f, error_ = load(line_of_code, table.unpack(args))
	end

	if f == nil then
	    print("Compilation error: " .. error_)
	else
	    local success, result = pcall(f)
	    if success then
		if result == exit_signal then break end
	    	if result ~= nil then print(inspect(result)) end
	    else
	    	print("Runtime error: " .. result)
	    end
	end

	line_counter = line_counter + 1
    end
end
