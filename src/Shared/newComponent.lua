local Matter = require(script.Parent.Parent.Parent.Matter)
local newComponent = Matter.component

return function(name, tbl)
	local component = newComponent(name)
	component.schema = function()
		return true
	end
	component.shouldReplicate = function()
		return true
	end
	
	function component.new(data)
		local comp
		if component.defaults then
			comp = table.freeze(setmetatable(Matter.merge(component.defaults, data), component))
		else
			comp = table.freeze(setmetatable(data or {}, component))
		end
		
		assert(component.schema(comp))
		return comp
	end
	
	function component:patch(partialNewData)
		debug.profilebegin("patch")
		local patch = getmetatable(self).new(Matter.merge(self, partialNewData))
		debug.profileend()
		return patch
	end
	
	if tbl then
		for k, v in pairs(tbl) do
			component[k] = v
		end
	end
	
	return component
end