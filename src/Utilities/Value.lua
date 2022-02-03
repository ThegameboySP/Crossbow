local Value = {}
Value.__index = Value

function Value.new(default, checker)
	local event = Instance.new("BindableEvent")

	return setmetatable({
		_value = default;
		Changed = event.Event;
		_event = event;
		_checker = checker
	}, Value)
end

function Value:OnChanged(handler)
	if self._value ~= nil then
		handler(self._value)
	end

	return self.Changed:Connect(handler)
end

function Value:Set(value)
	if self._checker then
		assert(self._checker(value))
	end
	
	local old = self._value
	if old ~= value then
		self._value = value
		self._event:Fire(value, old)
	end
end

function Value:Get()
	return self._value
end

return Value