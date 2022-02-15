local Registry = {}
Registry.__index = Registry

function Registry.new()
	return setmetatable({
		valuesSet = setmetatable({}, {__mode = "k"});
		valuesByIdentifier = {};
	}, Registry)
end

function Registry:rebuild()
	local valuesByIdentifier = self.valuesByIdentifier
	table.clear(valuesByIdentifier)

	local tab = 0
	for identifiers in pairs(self.valuesSet) do
		for _, entry in pairs(identifiers) do
			local str
			if tab <= 255 then
				str = string.char(tab)
			elseif tab <= 65535 then
				str = string.char(
					bit32.band(tab, 0xFF),
					bit32.rshift(bit32.band(tab, 0xFF00), 8)
				)
			else
				error("went above 65,535 items")
			end

			entry.id = str
			valuesByIdentifier[str] = entry
			tab += 1
		end
	end
end

local valuesMt = {
	__index = function(_, k)
		error(("No value named %q!"):format(k))
	end;
}

local entryMt = {
	__tostring = function(t)
		return t.id
	end;
}

function Registry:New(valuesTbl)
	local values = setmetatable({}, valuesMt)
	self.valuesSet[values] = true

	if valuesTbl[1] then
		for _, name in pairs(valuesTbl) do
			values[name] = setmetatable({id = 0}, entryMt)
		end
	else
		for name in pairs(valuesTbl) do
			values[name] = setmetatable({id = 0}, entryMt)
		end
	end

	self:rebuild()

	return values
end

return Registry