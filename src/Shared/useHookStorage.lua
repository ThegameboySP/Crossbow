local Matter = require(script.Parent.Parent.Parent.Matter)

return function(discriminator, cleanupFn)
	return Matter.useHookState(discriminator, cleanupFn)
end