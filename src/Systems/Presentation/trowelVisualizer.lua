local CollectionService = game:GetService("CollectionService")

local Priorities = require(script.Parent.Parent.Priorities)
local Components = require(script.Parent.Parent.Parent.Components)

local function makeWall(trowelTool)
    local wall = Components.TrowelTool.buildTrowel(
        function() end,
        function() return true end,
        Instance.new("Model"),
        Vector3.zAxis,
        trowelTool,
        Vector3.yAxis,
        nil,
        Vector3.zero
    )

    for _, descendant in pairs(wall:GetDescendants()) do
        if descendant:IsA("JointInstance") then
            descendant.Parent = nil
        elseif descendant:IsA("BasePart") then
            CollectionService:AddTag(descendant, "Visualizer")
            descendant.Anchored = true
            descendant.CanCollide = false
            descendant.CanTouch = false
            descendant.CanQuery = false
            descendant.CastShadow = false

            if descendant.Name == "Brick" then
                local adornment = Instance.new("SelectionBox")
                adornment.Adornee = descendant
                adornment.Color3 = Color3.new(1, 1, 1)
                adornment.Transparency = 0.85
                adornment.Parent = descendant
            end

            descendant.Transparency = 0.6
        end
    end

    return wall
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

local FROM_COLOR = Color3.new(0.65, 0.65, 0.65)
local TO_COLOR = Color3.new(1, 1, 1)

local wall
local function trowelVisualizer(world, params)
    if not params.Settings.TrowelTool.visualizationEnabled:Get() then
        if wall then
            wall.Parent = nil
        end
    
        return
    end
    
    local equippingTrowel, equippingTool
    for _id, tool, trowelTool in world:query(Components.Tool, Components.TrowelTool, Components.Owned) do
        if tool.isEquipped then
            equippingTool = tool
            equippingTrowel = trowelTool
            break
        end
    end

    if equippingTool then
        wall = wall or makeWall(equippingTrowel)
        wall.Parent = workspace

        raycastParams.FilterDescendantsInstances = {wall}
        local worldPos, part = params.Crossbow.Input:Raycast(params.Settings.Callbacks[equippingTrowel.raycastFilter], raycastParams)

        local lookDir = equippingTrowel:getLookDirection(equippingTool:getDirection(worldPos, "Head"))
        local rounded = equippingTrowel:getRoundedOrigin(worldPos, part)
    
        wall.PrimaryPart.PivotOffset = CFrame.lookAt(Vector3.zero, Vector3.zero + Vector3.new(-lookDir.X, 0, lookDir.Z))
        wall:PivotTo(CFrame.new(rounded))

        local alpha = math.sin(params.currentFrame)
        local color = FROM_COLOR:lerp(TO_COLOR, alpha)
            
        for _, descendant in pairs(wall:GetDescendants()) do
            if descendant:IsA("BasePart") then
                descendant.Color = color
            elseif descendant:IsA("SelectionBox") then
                local selectionColor = color:lerp(Color3.new(0.8, 0, 1), 0.2)
                descendant.Color3 = selectionColor
            end
        end
    elseif wall then
        wall.Parent = nil
    end
end

return {
    realm = "client";
    system = trowelVisualizer;
    event = "PostSimulation";
    priority = Priorities.Presentation;
}