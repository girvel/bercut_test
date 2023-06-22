--- Toolkit with general-usage functions
return {
    --- Merge two tables to one; prioritizes values from the second table
    merge_tables = function(t1, t2)
	local result = {}

	for key, value in pairs(t1) do
	    result[key] = value
	end

	for key, value in pairs(t2) do
	    result[key] = value
	end

	return result
    end,
}

