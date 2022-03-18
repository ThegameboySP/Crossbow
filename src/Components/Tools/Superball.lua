local t = require(script.Parent.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)

return function(settings)
	return newComponent("Superball", {
        index = {
            maxBounces = settings.Superball.maxBounces;
        };

        schema = {
            bouncePauseTime = t.number;
            bounces = t.number;
            lastHitTimestamp = t.number;
        };
    })
end