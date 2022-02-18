local t = require(script.Parent.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)

return function(settings)
	return newComponent("ExplodeOnTouch", {
		index = {
			getTouchedSignal = settings.Interfacing.getTouchedSignal;
		};

		defaults = {
			filter = function() return true end;
			transform = function(...)
				return ...
			end;
		};

		schema = {
			filter = t.callback;
			radius = t.number;
			damage = t.number;
			transform = t.callback;
		};
	})
end