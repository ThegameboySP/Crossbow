local Crossbow = require(script.Parent.Parent.Crossbow)
local RemoteEventMock = require(script.Parent.RemoteEventMock)
local Signal = require(script.Parent.Parent.Utilities.Signal)

-- Override task.spawn for breakpoint inspection.
Signal.RunHandler = coroutine.resume

local SIGNAL_ORDER = {"PreRender", "PreSimulation", "PostSimulation"}

return function(systems, isServer)
	local crossbow = Crossbow.new()
	crossbow.IsServer = isServer
	crossbow.IsTesting = true
	crossbow.Params.remoteEvent = RemoteEventMock.new()

	local runFunctions = {}
	crossbow:Init(systems, function(middleware)
		local signals = {
			PreRender = Signal.new();
			PreSimulation = Signal.new();
			PostSimulation = Signal.new();
		}

		for signalName, signal in pairs(signals) do
			runFunctions[signalName] = middleware(function()
				signal:Fire()
			end, signalName)
		end

		return signals
	end)
	
	return function(manualName)
		if manualName then
			runFunctions[manualName]()
		else
			for _, name in ipairs(SIGNAL_ORDER) do
				runFunctions[name]()
			end
		end
	end, crossbow
end