local Signal = require(script.Parent.Signal)

local Value = {}
Value.__index = Value

function Value.new(default, validator)
	return setmetatable({
		_value = default;
		_signal = Signal.new();
		validator = validator;
	}, Value)
end

function Value:OnChanged(handler)
	local value = self:Get()
	if value ~= nil then
		handler(value)
	end

	return self._signal:Connect(handler)
end

function Value:Connect(handler)
	return self._signal:Connect(handler)
end

function Value:Set(value)
	if self.validator then
		assert(self.validator(value))
	end
	
	local old = self._value
	if old ~= value then
		self._value = value
		self._signal:Fire(value, old)
	end
end

function Value:Get()
	return self._value
end

return {
	new = Value.new;
	is = function(value)
		return type(value) == "table" and getmetatable(value) == Value
	end;
}