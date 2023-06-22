describe("shifting array", function()
    local shifting_array = require("shifting_array")

    it("shifts its indexes", function()
	local array = shifting_array({1, 2, 3})

	array:shift(3)
	assert.same(array:render(), {nil, nil, nil, 1, 2, 3})
    end)
end)
