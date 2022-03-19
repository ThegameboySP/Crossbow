local Priorities = require(script.Parent.Parent.Priorities)

local function runPresentationHandlers(_, _, params)
    for _, event in ipairs(params.events:get("queuePresentation")) do
        event[1](unpack(event, 2, event.n))
    end
end

return {
    realm = "client";
    system = runPresentationHandlers;
    event = "PostSimulation";
    priority = Priorities.Presentation;
}