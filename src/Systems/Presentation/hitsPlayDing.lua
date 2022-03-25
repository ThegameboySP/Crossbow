local Priorities = require(script.Parent.Parent.Priorities)

local function hitsPlayDing(world, components, params)
    for _, damagedRecord in params.events:iterate("damaged") do
        if damagedRecord.sourceId and world:get(damagedRecord.sourceId, components.SwordTool) then
            continue
        end

        params.events:fire("playSound", params.Settings.Sounds.successfulHit)
    end
end

return {
    realm = "client";
    system = hitsPlayDing;
    event = "PostSimulation";
    priority = Priorities.Presentation;
}