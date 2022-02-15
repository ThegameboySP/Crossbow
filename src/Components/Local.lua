local newComponent = require(script.Parent.Parent.Shared.newComponent)
return function()
	return newComponent("Local", {
		noReplicate = true;
	})
end