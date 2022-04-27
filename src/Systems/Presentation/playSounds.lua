local Priorities = require(script.Parent.Parent.Priorities)

local function playSounds(_, _, params)
    params.soundPlayer:step()
end

return {
    realm = "client";
    system = playSounds;
    event = "PostSimulation";
    priority = Priorities.Presentation + 9;
}