local t = require(script.Parent.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)

local function roundSmall(n)
	return math.abs(n) < 1e-10 and 0 or n
end

local function round(n, base)
	return (n + base / 2) - (n + base / 2) % base
end

return function(settings)
	return newComponent("TrowelTool", {
		toolType = "Misc";

		index = {
			raycastFilter = settings.TrowelTool.raycastFilter;
            shouldWeld = settings.TrowelTool.shouldWeld;
			reloadTime = settings.TrowelTool.reloadTime;
			prefab = settings.TrowelTool.prefab;
			pack = settings.TrowelTool.pack;

            rotationStep = settings.TrowelTool.rotationStep;
            bricksPerRow = settings.TrowelTool.bricksPerRow;
            bricksPerColumn = settings.TrowelTool.bricksPerColumn;
            brickSpeed = settings.TrowelTool.brickSpeed;
		};

        schema = {
            rotation = t.number;
            isLocked = t.boolean;
            buildSound = t.optional(t.Instance);
        };

        getAutomaticRotation = function(self, charToTrowelDir)
            return round(math.atan2(-charToTrowelDir.Z, charToTrowelDir.X), math.rad(self.rotationStep)) + math.pi/2
        end;
        
        getLookDirection = function(self, charToTrowelDir)
            local rot = self.isLocked
                and math.rad(self.rotation)
                or self:getAutomaticRotation(charToTrowelDir)
        
            return Vector3.new(roundSmall(math.sin(rot)), 0, roundSmall(math.cos(rot))).Unit
        end;
        
        getRoundedOrigin = function(_, origin, part)
            if part then
                origin -= part.Position + part.Size/2
            end
        
            local roundedOrigin = Vector3.new(math.round(origin.X), math.round(origin.Y), math.round(origin.Z))
            if part then
                roundedOrigin += part.Position + part.Size/2
            end
        
            return roundedOrigin
        end
	})
end