local t = require(script.Parent.Parent.Parent.t)
local Layers = require(script.Parent.Layers)

return function()
	it("should create a layer", function()
		expect(Layers.new():create("test"):get()).to.equal("test")
	end)

	it("should set a layer", function()
		local layers, layer = Layers.new():create("test")
		expect(layers:get()).to.equal("test")
		layers, layer = layers:set(layer, "test2")
		expect(layers:get()).to.equal("test2")
	end)

	it("should remove a layer", function()
		local layers, layer = Layers.new():create("test")
		expect(layers:get()).to.equal("test")
		layers = layers:remove(layer)
		expect(layers:get()).to.equal(nil)
	end)

	it("should create layers at priority", function()
		local vars = {}
		vars.layers, vars.layer1 = Layers.new():create("1")
		vars.layers, vars.layer2 = vars.layers:createAtPriority(1, "2")
		expect(vars.layers:get()).to.equal("2")

		vars.layers, vars.layer0 = vars.layers:createAtPriority(-1, "0")
		expect(vars.layers:get()).to.equal("2")

		vars.layers, vars.layer3 = vars.layers:createAtPriority(2, "3")
		expect(vars.layers:get()).to.equal("3")
	end)

	it("should use transforms", function()
		expect(
			Layers.new({
				1,
				Layers.ops.add(2),
				Layers.ops.mul(4),
				Layers.ops.add(1)
			}):get()
		).to.equal(13)
	end)

	local function transformTableTest(wrapper)
		local layers = Layers.new({
			wrapper(table.freeze({test1 = true})),
			Layers.ops.merge(table.freeze({test2 = true}))
		})

		expect(layers:get().test1).to.equal(true)
		expect(layers:get().test2).to.equal(true)
	end

	it("should copy transform's injected table before passing it to the next transforms", function()
		transformTableTest(Layers.ops.merge)
	end)

	it("should copy table before passing it to transforms", function()
		transformTableTest(function(tbl)
			return tbl
		end)
	end)

	it("should make a validator", function()
		local validator = Layers.validator(t.boolean)

		expect(validator({true})).to.equal(false)
		expect(validator(Layers.new({"not a boolean"}))).to.equal(false)
		expect(validator(Layers.new({true}))).to.equal(true)
	end)
end