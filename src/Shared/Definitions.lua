local t = require(script.Parent.Parent.Parent.t)

return {
	system = t.interface({
		realm = t.optional(t.valueOf({"server", "client"}));
	});

	component = t.interface({
		noReplicate = t.optional(t.boolean);
		index = t.optional(t.table);
		defaults = t.optional(t.table);
		schemaNotStrict = t.optional(t.boolean);
		schema = t.optional(t.table);
	});

	params = t.strictInterface({
		Crossbow = t.table;
		Packs = t.table;
		Settings = t.table;

		serverToClientId = t.table;
		clientToServerId = t.table;

		remoteEvent = t.any;
		
		events = t.table;
		remoteEvents = t.table;
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

	damageType = t.valueOf({"Hit", "Explosion", "Melee"});
}