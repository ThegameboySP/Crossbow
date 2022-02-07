local RunService = game:GetService("RunService")

local legacyNameMap = {
	RenderStepped = "PreRender";
	Stepped = "PreSimulation";
	Heartbeat = "PostSimulation";
}

return function(middleware)
	local signals = {
		RenderStepped = Instance.new("BindableEvent");
		Stepped = Instance.new("BindableEvent");
		Heartbeat = Instance.new("BindableEvent");
	}

	for signalName, signal in pairs(signals) do
		RunService[signalName]:Connect(middleware(function()
			signal:Fire()
		end, legacyNameMap[signalName]))
	end

	return {
		PreRender = signals.RenderStepped.Event;
		PreSimulation = signals.Stepped.Event;
		PostSimulation = signals.Heartbeat.Event;
	}
end