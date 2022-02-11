local t = require(script.Parent.Parent.Parent.t)

return {
	system = t.interface({
		realm = t.optional(t.valueOf({"server", "client"}));
	});

	params = t.strictInterface({
		Crossbow = t.table;

		remoteEvent = t.instanceIsA("RemoteEvent");
		
		events = t.table;
		entityKey = t.string;

		currentFrame = t.number;
		previousFrame = t.number;
		deltaTime = t.number;
	});

	patch = t.strictInterface({
		name = t.string;
		requires = t.optional(t.array(t.instanceIsA("ModuleScript")));

		systems = t.optional(t.array(t.instanceIsA("ModuleScript")));
		disabledSystems = t.optional(t.array(t.instanceIsA("ModuleScript")));
		components = t.optional(t.map(t.string, t.table));
		prefabs = t.optional(t.map(t.string, t.Instance));

		onActivated = t.optional(t.callback);
		onDeactivated = t.optional(t.callback);
	});
}