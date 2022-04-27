local Priorities = require(script.Parent.Parent.Priorities)

local handlers = {}
for _, child in pairs(script:GetChildren()) do
    handlers[child.Name] = require(child)
end

local function runPresentationHandlers(world, components, params)
    for _, event in ipairs(params.events:get("queuePresentation")) do
        event[1](unpack(event, 2, event.n))
    end

    for name, handler in pairs(handlers) do
        debug.profilebegin(name)

        xpcall(handler, function(err)
            task.spawn(error, err)
        end, world, components, params)

        debug.profileend()
    end
end

return {
    realm = "client";
    system = runPresentationHandlers;
    event = "PostSimulation";
    priority = Priorities.Presentation;
}