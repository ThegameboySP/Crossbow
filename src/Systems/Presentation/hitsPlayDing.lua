local Priorities = require(script.Parent.Parent.Priorities)

local function hitsPlayDing(_, _, params)
    for _ in params.events:iterate("damaged") do
        params.events:fire("playSound", params.Settings.Sounds.successfulHit)
    end
end

return {
    realm = "client";
    system = hitsPlayDing;
    event = "PostSimulation";
    priority = Priorities.Presentation;
}