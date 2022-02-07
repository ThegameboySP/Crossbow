local components = {}

for _, module in pairs(script:GetChildren()) do
	components[module.Name] = require(module)
end

return setmetatable(components, {__index = function(_, k)
	error(("No component named %q!"):format(k), 2)
end})