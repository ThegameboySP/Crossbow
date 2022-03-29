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

    if coroutine.status(state.coroutine) == "dead" then
        return false, select(2, ...)
    end

    return true, select(2, ...)
end

local function useCoroutine(callback, discriminator, ...)
    local state = useHookState(discriminator, cleanup)

    if not state.coroutine then
        state.coroutine = coroutine.create(callback)
        local sleep = function(time, ...)
            state.timeToAwake = os.clock() + time
            coroutine.yield(...)
        end

        return transform(state, coroutine.resume(state.coroutine, sleep, ...))
    elseif not state.timeToAwake or state.timeToAwake - os.clock() > 0 then
        return true
    end

    state.timeToAwake = nil

    return transform(state, coroutine.resume(state.coroutine))
end

return useCoroutine