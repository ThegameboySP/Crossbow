local Matter = require(script.Parent.Parent.Parent.Matter)
local t = require(script.Parent.Parent.Parent.t)
local Definitions = require(script.Parent.Definitions)
local newComponent = Matter.component

return function(name, tbl)
	local component = newComponent(name)
	
	function component.new(data)
		local comp
		if component.defaults then
			comp = table.freeze(setmetatable(Matter.merge(component.defaults, data), component))
		else
			comp = table.freeze(setmetatable(data or {}, component))
		end
		
		local ok, err = component.schema(comp)
		if not ok then
			error(string.format("Cannot patch %q: %s", tostring(component), err or ""))
		end

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

	local schema = component.schema or {}
	if tbl and tbl.index then
		component.defaults = component.defaults or {}
		tbl.schema = tbl.schema or {}

		for key, value in pairs(tbl.index) do
			-- TODO: does not support hot reloading, as there is no way to clear the connection.
			value:OnChanged(function(changedValue)
				component.defaults[key] = changedValue
			end)
			schema[key] = value.validator or tbl.schema[key]
		end
	end
	
	assert(Definitions.component(component))

	if component.schema and component.schemaNotStrict then
		component.schema = t.interface(schema)
	elseif component.schema and not component.schemaNotStrict then
		component.schema = t.strictInterface(schema)
	else
		component.schema = function()
			return true
		end
	end

	return component
end