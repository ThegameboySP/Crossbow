local useHookState = require(script.Parent.Parent.Parent.Matter).useHookState

local function transform(state, timestamp, ...)
    if ... == false then
        table.clear(state)
        error(debug.traceback(state.coroutine, tostring(select(..., 2))))
    end

    if coroutine.status(state.coroutine) == "dead" then
        table.clear(state)
        return false, select(3, ...)
    end

    state.awakeTime = timestamp + select(2, ...)

    return true, select(3, ...)
end

return function(callback, discriminator, timestamp, ...)
    local state = useHookState(discriminator)

    if not state.coroutine then
        state.coroutine = coroutine.create(callback)
        return transform(state, timestamp, coroutine.resume(state.coroutine, ...))
    elseif state.awakeTime - timestamp > 0 then
        return true
    end

    return transform(state, timestamp, coroutine.resume(state.coroutine))
end