local timeout_error = "Coroutine timeout"

return {
    sleep = function(seconds)
	-- consumes CPU, potentially needs blocking sleep function from external library function or OS-dependent
	-- utilities such as Linux `sleep`

	local end_time = os.time() + seconds
	while os.time() < end_time do
	    coroutine.yield()
	end
    end,

    run_multiple = function(functions, timeout, error_handler)
	-- Create coroutines
	local coroutines = {}
	for position, f in pairs(functions) do
	    coroutines[position] = coroutine.create(f)
	end

	local start_time = os.time()
	local overhead = 0

	-- Run created coroutines simultaneously
	while true do
	    local counter = 0
	    local ended_coroutines = {}

	    for position, current_coroutine in pairs(coroutines) do
	    	counter = counter + 1

		if os.time() - start_time > timeout + overhead then
		    table.insert(ended_coroutines, position)
		    error_handler(position, timeout_error)
		end

		local success, result = coroutine.resume(current_coroutine, position)

		if coroutine.status(current_coroutine) == "dead" then
		    table.insert(ended_coroutines, position)

		    if not success then
			local time = os.time()
			error_handler(position, result)
			overhead = overhead + os.time() - time
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

    timeout_error = timeout_error,
}

