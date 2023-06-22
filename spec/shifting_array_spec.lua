describe("shifting array", function()
    local shifting_array = require("shifting_array")

    it("shifts its indexes", function()
	local array = shifting_array({1, 2, 3})

	array:shift(3)
	local i = require "lib.inspect"
	print(i(array:render()))
	assert.same(array:render(), {nil, nil, nil, 1, 2, 3})
    end)
end)
