return {
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
