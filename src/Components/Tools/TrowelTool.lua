local CollectionService = game:GetService("CollectionService")

local t = require(script.Parent.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)
local General = require(script.Parent.Parent.Parent.Utilities.General)
local Raycaster = require(script.Parent.Parent.Parent.Utilities.Raycaster)

local function roundSmall(n)
	return math.abs(n) < 1e-10 and 0 or n
end

local function round(n, base)
	return (n + base / 2) - (n + base / 2) % base
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

local function getNormalIdFromVector(v)
	if v:FuzzyEq(Vector3.xAxis) then
		return Enum.NormalId.Right
	elseif v:FuzzyEq(-Vector3.xAxis) then
		return Enum.NormalId.Left
	elseif v:FuzzyEq(Vector3.yAxis) then
		return Enum.NormalId.Top
	elseif v:FuzzyEq(-Vector3.yAxis) then
		return Enum.NormalId.Bottom
	elseif v:FuzzyEq(Vector3.zAxis) then
		return Enum.NormalId.Front
	elseif v:FuzzyEq(-Vector3.zAxis) then
		return Enum.NormalId.Back
	end

	return nil
end

local function raycastFilter(part, shouldWeld)
	if CollectionService:HasTag(part, "Visualizer") then
		return false
	end

	local normalId = getNormalIdFromVector(part.CFrame:VectorToWorldSpace(Vector3.yAxis))
	
	return normalId and shouldWeld(part, normalId)
end

local function makeJoint(brick, normal, shouldWeld)
	local results = Raycaster.withFilter(
		brick.Position - Vector3.yAxis * brick.Size * 0.4999,
		-normal * 0.01,
		raycastParams,
		raycastFilter,
		shouldWeld
	)

	if results then
	    General.weld(brick, results.Instance)
    end
end

local function buildTrowel(sleep, shouldWeld, model, lookDir, trowelTool, normal, part, pos)
    local brickLength = trowelTool.prefab.Size.X
    local brickHeight = trowelTool.prefab.Size.Y

    local middleOffset = (brickLength * trowelTool.bricksPerRow) / 2
	local crossDir = lookDir:Cross(Vector3.yAxis)
	local middleTransformed = crossDir * middleOffset
	local roundedOrigin = trowelTool:getRoundedOrigin(pos - middleTransformed, part)

    local CF = CFrame.lookAt(roundedOrigin, roundedOrigin + lookDir)

    local primaryPart = Instance.new("Part")
    primaryPart.CFrame = CF * CFrame.new(middleOffset, 0, 0)
    primaryPart.Size = Vector3.zero
    primaryPart.Anchored = true
    primaryPart.CanCollide = false
    primaryPart.CanTouch = false
    primaryPart.CanQuery = false
    primaryPart.Parent = model
    model.PrimaryPart = primaryPart
    
    local totalBricks = trowelTool.bricksPerColumn * trowelTool.bricksPerRow
    local brickSpeed = trowelTool.brickSpeed * (totalBricks / (totalBricks - trowelTool.bricksPerRow))

    for y=0, trowelTool.bricksPerColumn - 1 do
        for x=0, trowelTool.bricksPerRow - 1 do
            local nextBrick = trowelTool.prefab:Clone()
            nextBrick.Name = "Brick"
            nextBrick.Parent = model

            nextBrick.CFrame = CF * CFrame.new(
                x*brickLength + brickLength/2,
                y*brickHeight + brickHeight/2,
                0
            )

            makeJoint(nextBrick, normal, shouldWeld)

            if y > 0 then
                sleep(brickSpeed)
            else
                nextBrick.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0, 0.5)
            end
        end
    end

    return model
end

return newComponent("TrowelTool", {
    toolType = "Misc";
    buildTrowel = buildTrowel;

    schema = {
        rotation = t.number;
        isLocked = t.boolean;
        buildSound = t.optional(t.Instance);
        
        raycastFilter = t.string;
        shouldWeld = t.string;
        prefab = t.Instance;
        pack = t.string;

        rotationStep = t.number;
        bricksPerRow = t.number;
        bricksPerColumn = t.number;
        brickSpeed = t.number;
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