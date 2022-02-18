local Layers = {}
Layers.__index = Layers

local NONE = {}
local cache = setmetatable({}, {__mode = "k"})

local function isTransform(layer)
	return type(layer.value) == "table" and layer.value.__transform ~= nil
end

local function computeTransforms(layers)
	local resolved
	local index = 1
	for i=#layers, 1, -1 do
		local layer = layers[i]
		local layerValue = layer.value

		if isTransform(layer) then
			continue
		end

		resolved = layerValue
		index = i + 1
		break
	end
	
	-- Copy the table so transforms can mutate it.
	if type(resolved) == "table" then
		local copy = {}
		for k, v in pairs(resolved) do
			copy[k] = v
		end
		resolved = copy
	end
	
	for i=index, #layers do
		local layerValue = layers[i].value
		local nextResolved = layerValue.__transform(resolved)

		-- If transform's parameter was nil, it returned its injected table.
		-- Copy it so other transforms can safely mutate it.
		if resolved == nil and type(nextResolved) == "table" then
			resolved = {}
			for k, v in pairs(nextResolved) do
				resolved[k] = v
			end
		else
			resolved = nextResolved
		end
	end
	
	return resolved
end

function Layers.new(data)
	if data then
		local layers = {}
		for index, value in ipairs(data) do
			layers[index] = {value = value, priority = 0}
		end
		return table.freeze(setmetatable(layers, Layers))
	end
	
	return table.freeze(setmetatable({}, Layers))
end

function Layers:create(value, name)
	local layer = table.freeze({value = value, priority = 0, name = name})
	local copy = setmetatable({unpack(self)}, Layers)
	table.insert(copy, layer)
	return table.freeze(copy), layer
end

function Layers:set(layer, value)
	local index = table.find(self, layer)
	if index == nil then
		return self, layer
	end
	
	local newLayer = table.freeze({value = value, priority = layer.priority})
	local copy = setmetatable({unpack(self)}, Layers)
	copy[index] = newLayer
	return table.freeze(copy), newLayer
end

function Layers:createAtPriority(priority, value)
	local newLayer = table.freeze({value = value, priority = priority})
	
	local chosenIndex = 1
	for index = #self, 1, -1 do
		if self[index].priority <= priority then
			chosenIndex = index + 1
			break
		end
	end

	local copy = setmetatable({unpack(self)}, Layers)
	table.insert(copy, chosenIndex, newLayer)
	
	return table.freeze(copy), newLayer
end

function Layers:remove(layer)
	local index = table.find(self, layer)
	if index then
		local copy = setmetatable({unpack(self)}, Layers)
		table.remove(copy, index)
		return table.freeze(copy)
	end
	
	return self
end

function Layers:has(layer)
	return if table.find(self, layer) then true else false
end

function Layers:getLayer(name)
	for _, layer in pairs(self) do
		if layer.name == name then
			return layer
		end
	end
	
	return nil
end

function Layers:get()
	local resolved = cache[self]
	if resolved then
		return if resolved == NONE then nil else resolved
	end
	
	local finalLayer = self[#self]
	if finalLayer == nil then
		return nil
	end
	
	if not isTransform(finalLayer) then
		cache[self] = if finalLayer.value == nil then NONE else finalLayer.value
		return finalLayer.value
	end
	
	resolved = computeTransforms(self)
	cache[self] = if resolved == nil then NONE else resolved
	return resolved
end

local function is(value)
	return type(value) == "table" and getmetatable(value) == Layers
end

local function wrap(transform)
	return {__transform = transform}
end

local op = function(def, func)
	return function(n)
		return wrap(function(c)
			return func(c or def, n)
		end)
	end
end

return {
	new = Layers.new;
	is = is;
	validator = function(validator)
		return function(layers)
			if not is(layers) then
				return false, "layer expected"
			end

			for _, layer in pairs(layers) do
				local ok, err = validator(layer.value)
				if not ok then
					return false, err
				end
			end

			return true
		end
	end;

	ops = {
		wrap = wrap;

		add = op(0, function(c, n) return c + n end);
		sub = op(0, function(c, n) return c - n end);
		mul = op(1, function(c, n) return c * n end);
		div = op(1, function(c, n) return c / n end);
		mod = op(0, function(c, n) return c % n end);

		join = function(this)
			return wrap(function(with)
				local copy = with and {unpack(with)} or {}
				for _, value in ipairs(this) do
					table.insert(copy, value)
				end
				return copy
			end)
		end;
		
		merge = function(this)
			return wrap(function(with)
				local copy = {}
				for k, v in pairs(this) do
					copy[k] = v
				end

				if with == nil then
					return copy
				end
		
				for k, v in pairs(with) do
					copy[k] = v
				end
				return copy
			end)
		end
	}
}