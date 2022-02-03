local CollectionService = game:GetService("CollectionService")

local Raycaster = {}

local PASS = function()
	return true
end

local function NORMAL(origin, dir, params)
	return workspace:Raycast(origin, dir, params)
end

local DEFAULT_PARAMS = RaycastParams.new()

local function raycast(origin, dir, func, params, filter, ...)
	local result = func(origin, dir, params)
	local hitPart = result and result.Instance

	if 
		result
		and (CollectionService:HasTag(hitPart, "RaycastIgnore") or not filter(hitPart, ...))
	then
		local resolvedParams = params or DEFAULT_PARAMS
		local filterDescendants = resolvedParams.FilterDescendantsInstances

		-- FilterDescendantsInstances change seems to only take effect if you create an entirely new table.
		if resolvedParams.FilterType == Enum.RaycastFilterType.Blacklist then
			resolvedParams.FilterDescendantsInstances = {result.Instance, unpack(filterDescendants or {})}
		else
			-- TODO: test
			local copy = {}
			table.move(filterDescendants, 1, #filterDescendants, 1, copy)

			repeat
				local index = table.find(copy, hitPart)
				if index then
					table.remove(copy, index)
				end
			until index == nil

			resolvedParams.FilterDescendantsInstances = copy
		end

		local hitPoint = result.Position
		local backward = dir.Unit * 0.001
		local newOrigin = hitPoint - backward
		local delta = hitPoint - origin
		local newDir = (dir + backward) - delta

		local nextResult = raycast(newOrigin, newDir, func, resolvedParams, filter, ...)
		resolvedParams.FilterDescendantsInstances = filterDescendants
		return nextResult
	end
	
	return result
end

function Raycaster.withFilter(origin, dir, params, filter, ...)
	return raycast(origin, dir, NORMAL, params, filter or PASS, ...)
end

function Raycaster.raycast(origin, dir, params)
	return raycast(origin, dir, NORMAL, params, PASS)
end

return Raycaster
