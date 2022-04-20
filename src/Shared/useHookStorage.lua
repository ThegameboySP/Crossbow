local Matter = require(script.Parent.Parent.Parent.Matter)

local function useHookStorage(discriminator, initState, cleanupFn)
	local state = Matter.useHookState(discriminator, cleanupFn)
	if initState and not next(state) then
		initState(state)
	end

	return state
end

return useHookStorage