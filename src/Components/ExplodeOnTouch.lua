local t = require(script.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Shared.newComponent)
local Layers = require(script.Parent.Parent.Utilities.Layers)

return function(settings)
	return newComponent("ExplodeOnTouch", {
		index = {
			connectTouched = settings.Rules.connectTouched;
		};

		schema = {
			filter = t.callback;
			radius = t.number;
			damage = Layers.validator(t.number);
		};
	})
end