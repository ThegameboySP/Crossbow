local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)
local t = require(script.Parent.Parent.Parent.Parent.t)

local function getLaunchAngle(dx, dy, speed, grav)
	local sqSpeed = speed ^ 2
	
	local inRoot = sqSpeed^2 - (grav * ((grav * dx^2) + (2 * dy * sqSpeed)))

	if inRoot <= 0 then
		return -1
	end

	local root = math.sqrt(inRoot)
	local gravDist = grav * dx

	local inATan1 = (sqSpeed + root) / gravDist
	local inATan2 = (sqSpeed - root) / gravDist

	local answer1 = math.atan(inATan1)
	local answer2 = math.atan(inATan2)

	if answer1 < answer2 then 
		return answer1 
	end

	return answer2
end

return newComponent("SlingshotTool", {
	toolType = "Projectile";
	getProjectileCFrame = function(tool, spawnDistance, hitPoint, self)
		local spawnDir = tool:getDirection(hitPoint, "Head")
		local launch = tool:getPosition("Head") + spawnDir * spawnDistance
		local delta = hitPoint - launch

		local deltaYConstrained = Vector3.new(delta.X, 0, delta.Z)
		local unitDelta = deltaYConstrained.Unit

		local theta = getLaunchAngle(deltaYConstrained.Magnitude, delta.Y, self.velocity, workspace.Gravity)
		local dir
		if theta == -1 then
			dir = Vector3.new(spawnDir.X, spawnDir.Y + 0.3, spawnDir.Z)
		else
			local vy = math.sin(theta)
			local xz = math.cos(theta)
			dir = Vector3.new(unitDelta.X * xz, vy, unitDelta.Z * xz)
		end

		return CFrame.lookAt(launch, launch + dir)
	end;

	schema = {
		raycastFilter = t.string;
		velocity = t.number;
		spawnDistance = t.number;
		prefab = t.Instance;
		pack = t.string;
	};
})