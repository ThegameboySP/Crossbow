local Crossbow = require(script.Parent.Parent.Crossbow)
local RemoteEventMock = require(script.Parent.RemoteEventMock)
local Signal = require(script.Parent.Signal)

local function createSignals()
	-- Use a custom signal for breakpoint inspection.
	return {
		PreRender = Signal.new();
		PreSimulation = Signal.new();
		PostSimulation = Signal.new();
	}
end

local function getRunFns(signals, middleware)
	local runFns = {}
	for signalName, signal in pairs(signals) do
		runFns[signalName] = middleware(function()
			signal:Fire()
		end, signalName)
	end

	return runFns
end

local SIGNAL_ORDER = {"PreRender", "PreSimulation", "PostSimulation"}

return function(systems, isServer)
	local crossbow = Crossbow.new()
	if isServer ~= nil then
		crossbow.IsServer = isServer
	end
	crossbow.IsTesting = true
	crossbow:PopulateParams()
	
	crossbow.Params.remoteEvent = RemoteEventMock.new()
	crossbow.Loop:scheduleSystems(systems)

	local signals = createSignals()
	local runFns = getRunFns(signals, function(nextFn, signalName)
		return function()
			nextFn()

			if signalName == "PostSimulation" then
				table.clear(crossbow.Params.events)
			end
		end
	end)

	crossbow.Loop:begin(signals)

	return function(manualName)
		if manualName then
			runFns[manualName]()
		else
			for _, name in ipairs(SIGNAL_ORDER) do
				runFns[name]()
			end
		end
	end, crossbow
end