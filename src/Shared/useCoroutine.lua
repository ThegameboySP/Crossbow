local useHookState = require(script.Parent.Parent.Parent.Matter).useHookState

local function cleanup(state)
    coroutine.close(state.coroutine)
end

local function transform(state, ...)
    if ... == false then
        task.spawn(
            error,
            debug.traceback(state.coroutine, tostring(select(2, ...)))
        )
    end

    for i=2, select("#", ...) do
        table.insert(state.args, select(i, ...))
    end
end

local function useCoroutine(callback, discriminator, dt, ...)
    local state = useHookState(discriminator, cleanup)

    if not state.coroutine then
        state.coroutine = coroutine.create(callback)
        state.args = {}

        local sleep = function(time, ...)
            state.timeToAwake = time
            coroutine.yield(...)
        end

        transform(state, coroutine.resume(state.coroutine, sleep, ...))
    end

    while dt > 0 and coroutine.status(state.coroutine) == "suspended" do
        if state.timeToAwake > 0 then
            local madeUp = math.min(state.timeToAwake, dt)
            state.timeToAwake -= madeUp
            dt -= madeUp

            if state.timeToAwake > 0 then
                break
            end
        end

        transform(state, coroutine.resume(state.coroutine, ...))
    end

    local args = state.args
    if args[1] then
        state.args = {}
    end

    return coroutine.status(state.coroutine) == "suspended", args
end

return useCoroutine