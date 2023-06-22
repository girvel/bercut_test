--- Basic async/await implementation
local async = {}


--- Wait for N seconds, allowing other coroutines to resume; basically await sleep(N)
-- @param seconds Minimal number of seconds to wait. Supports floats.
async.sleep = function(seconds)
    -- consumes CPU, potentially needs blocking sleep function from external library function or OS-dependent
    -- utilities such as Linux `sleep`

    local end_time = os.clock() + seconds
    while os.clock() < end_time do
	coroutine.yield()
    end
end

--- Run multiple functions asynchronously
-- @param functions Table of functions to run; any keys, function values.
-- @param timeout Maximal execution time in seconds; will raise "Timeout error" if exceeded; supports floats.
-- @param error_handler Function to handle errors inside the coroutines; receives key in `functions` of the failed
-- coroutine and the error itself.
async.run_multiple = function(functions, timeout, error_handler)
    error_handler = error_handler or function() end

    -- Create coroutines
    local coroutines = {}
    for position, f in pairs(functions) do
	coroutines[position] = coroutine.create(f)
    end

    local start_time = os.clock()
    local overhead = 0

    -- Run created coroutines simultaneously
    while true do
	local counter = 0
	local ended_coroutines = {}

	for position, current_coroutine in pairs(coroutines) do
	    counter = counter + 1

	    if timeout and os.clock() - start_time > timeout + overhead then
		table.insert(ended_coroutines, position)
		error_handler(position, async.timeout_error)
	    end

	    local success, result = coroutine.resume(current_coroutine, position)

	    if coroutine.status(current_coroutine) == "dead" then
		table.insert(ended_coroutines, position)

		if not success then
		    local time = os.clock()
		    error_handler(position, result)
		    overhead = overhead + os.clock() - time
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
end

--- Timeout error message
async.timeout_error = "Async timeout"


return async
