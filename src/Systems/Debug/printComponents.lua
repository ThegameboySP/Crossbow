local function printComponents(world, components)
	-- for _, definition in pairs(components) do
	-- 	for id, record in world:queryChanged(definition) do
	-- 		local action =
	-- 			if record.new and not record.old then "[inserted]"
	-- 			elseif record.new and record.old then "[changed]"
	-- 			else "[removed]"
			
	-- 		print(action, id, definition.componentName)
	-- 	end
	-- end
end

return {
	system = printComponents;
	priority = 200;
	event = "PostSimulation";
}