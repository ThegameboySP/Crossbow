--[[
	MIT License

Copyright (c) 2021 sayhisam1

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local RunService = game:GetService("RunService")

local HotReloader = {}
HotReloader.__index = HotReloader

function HotReloader.new()
	local self = setmetatable({
		_listeners = {},
		_clonedModules = {},
	}, HotReloader)
	return self
end

function HotReloader:destroy()
	for _, listener: RBXScriptSignal in pairs(self._listeners) do
		listener:Disconnect()
	end
	self._listeners = nil
	for _, cloned in pairs(self._clonedModules) do
		cloned:Destroy()
	end
	self._clonedModules = nil
end

function HotReloader:getLatest(module)
	return self._clonedModules[module] or module
end

function HotReloader:listen(module: ModuleScript, callback: (ModuleScript) -> nil, cleanup: (ModuleScript) -> nil)
	if RunService:IsStudio() then
        cleanup = cleanup or function() end
        
		local moduleChanged = module.Changed:Connect(function()
			if self._clonedModules[module] then
				cleanup(self._clonedModules[module])
				self._clonedModules[module]:Destroy()
			else
				cleanup(module)
			end

			local cloned = module:Clone()
			cloned.Parent = module.Parent
			self._clonedModules[module] = cloned

			callback(cloned)
			warn(("HotReloaded %s!"):format(module:GetFullName()))
		end)
		table.insert(self._listeners, moduleChanged)
	end
	callback(module)
end

return HotReloader