local t = require(script.Parent.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)

return function(settings)
	return newComponent("ExplodeOnTouch", {
		index = {
			getTouchedSignal = settings.Interfacing.getTouchedSignal;
		};

		schema = {
			filter = t.string;
			radius = t.number;
			damage = t.number;
			transform = t.string;
		};
	})
end