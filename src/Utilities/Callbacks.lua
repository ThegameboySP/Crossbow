local CollectionService = game:GetService("CollectionService")

local General = require(script.Parent.General)
local Raycaster = require(script.Parent.Raycaster)

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

local Callbacks = {}

function Callbacks.buildTrowel(sleep, shouldWeld, model, lookDir, trowelTool, normal, part, pos)
    local brickLength = trowelTool.prefab.Size.X
    local brickHeight = trowelTool.prefab.Size.Y

    local middleOffset = (brickLength * trowelTool.bricksPerRow) / 2
	local crossDir = lookDir:Cross(normal)
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

            if y == 0 then
                nextBrick.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0, 0.5)
            end
            
            sleep(trowelTool.brickSpeed)
        end
    end

    return model
end

return Callbacks