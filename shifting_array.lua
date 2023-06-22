--- Table-based array of numbers with guaranteed O(1) index shifting.
-- @param base_table Table with integer indexes to be taken as a base; taken by a reference.
return function(base_table)
    base_table = base_table or {}

    local minimal_index = math.huge
    for i, _ in pairs(base_table) do
	assert(type(i) == "number", "Only number indexes are allowed")
	minimal_index = math.min(minimal_index, i)
    end

    return setmetatable({
	_internal_table = base_table,
	_shift = 0,
	_minimal_index = minimal_index,

	--- Shift the array to the right with given offset
	-- @param offset Offset to shift the array with. Default is 1. Supports any natural number.
	shift = function(self, offset)
	    self._shift = self._shift + (offset or 1)
	end,

	--- Iterate through the array ignoring trailing nils
	iterate = function(self)
	    local iterator = ipairs(self)
	    return iterator, self, self._shift + self._minimal_index - 1
	end,

	--- Convert the array to a traditional lua table
	render = function(self)
	    local result = {}

	    for i, value in self:iterate() do
		result[i] = value
	    end

	    return result
	end,
    }, {
	__index = function(self, key)
	    if type(key) ~= "number" then
		return nil
	    end

	    return self._internal_table[key - self._shift]
	end,

	__newindex = function(self, key, value)
	    if type(key) ~= "number" then return end
	    
	    self._internal_table[key - self._shift] = value
	    self._minimal_index = math.min(self._minimal_index, key - self._shift)
	end
    })
end
