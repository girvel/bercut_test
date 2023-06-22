describe("shifting array", function()
    local shifting_array = require("shifting_array")

    it("shifts its indexes", function()
	local array = shifting_array({1, 2, 3})

	array:shift(3)
	assert.same(array:render(), {nil, nil, nil, 1, 2, 3})
    end)

    it("has working __newindex", function()
	local array = shifting_array()
	array[1] = 1
	assert.same(array._internal_table, {1})
    end)
end)
