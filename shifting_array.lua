--- Table-based array of numbers with guaranteed O(1) index shifting.
return function(base_table)
    return setmetatable({
	_internal_table = base_table and {table.unpack(base_table)} or {},
	_shift = 0,

	--- Shift the array to the right with given offset
	-- @param offset Offset to shift the array with. Default is 1. Supports any natural number.
	shift = function(self, offset)
	    self._shift = self._shift + (offset or 1)
	end,

	--- Iterate through the array ignoring trailing nils
	iterate = function(self)
	    local iterator = ipairs(self)
	    return iterator, self, self._shift
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
	    if type(key) ~= "number" then
		self._internal_table[key - self._shift] = value
	    end
	end
    })
end
