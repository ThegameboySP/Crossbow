local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)

return function()
	return newComponent("Owned", {
		noReplicate = true;
	})
end