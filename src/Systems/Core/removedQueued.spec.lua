local createTestEnvironment = require(script.Parent.Parent.Parent.Tests.createTestEnvironment)
local removeQueued = require(script.Parent.removeQueued)

return function()
	it("should destroy instance and despawn entity after no longer existing", function()
		local run, crossbow = createTestEnvironment({removeQueued})

		local parent = Instance.new("Folder")
		local instance = Instance.new("Folder")
		instance.Parent = parent
		local id = crossbow:SpawnBind(instance)
	
		run()
		expect(crossbow.World:contains(id)).to.equal(true)
		expect(instance.Parent).to.equal(parent)

		crossbow.Params.events:fire("queueRemove", id)
		run()
		expect(crossbow.World:contains(id)).to.equal(false)
		expect(instance.Parent).to.equal(nil)
	end)
end