local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
local Debris = game:GetService("Debris")

local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)
local Priorities = require(script.Parent.Parent.Priorities)

local random = Random.new()
local function spatter(part)
	for _ = 1, random:NextInteger(2, 3) do
		local debrisPart = Instance.new("Part")
		PhysicsService:SetPartCollisionGroup(debrisPart, "Crossbow_Visual")

		debrisPart.Name = "PaintballDebris"
		debrisPart.Size = Vector3.new(1, 0.4, 1)
		debrisPart.Color = part.Color

        local randomDistance = random:NextUnitVector() * random:NextNumber(0.1, 0.2)

		debrisPart.CFrame = CFrame.lookAt(part.Position + randomDistance, part.Position)
		debrisPart.AssemblyLinearVelocity = randomDistance * 15
		debrisPart.Parent = workspace
        
		Debris:AddItem(debrisPart, random:NextInteger(3, 5))
	end
end

local function showPaintballPellets(world, components, params)
    local currentFrame = params.currentFrame
    local partColors = useHookStorage()

    for part, entry in pairs(partColors) do
        if entry.revertTimestamp - currentFrame <= 0 then
            part.Color = entry.color
            partColors[part] = nil
        end
    end
    
    for id in world:query(components.PaintballPellet) do
        local queue = params.hitQueue[id]
        if queue == nil then
            continue
        end
        
        local part = world:get(id, components.Part)
        local filter = params.Settings.Callbacks[world:get(id, components.Ricochets).filter]

        for _, hit in ipairs(queue) do
            if filter(hit) then
                spatter(part.part)
                
                if hit.Anchored == false and not CollectionService:HasTag(hit, "Crossbow_Projectile") then
                    if partColors[hit] == nil then
                        partColors[hit] = {
                            color = hit.Color;
                            revertTimestamp = nil;
                        }
                    end

                    partColors[hit].revertTimestamp = currentFrame + 16
                    local color = hit.Color:lerp(part.part.Color, 0.5)
                    hit.Color = color
                    params.events:fire("paintballColored", hit, color)
                end
                
                break
            end
        end
    end
end

return {
    realm = "client";
    system = showPaintballPellets;
    event = "PostSimulation";
    priority = Priorities.Presentation;
}