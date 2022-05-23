local Components = {}

for _, child in pairs(script:GetDescendants()) do
    if child:IsA("ModuleScript") then
        Components[child.Name] = require(child)
    end
end

return setmetatable(Components, {__index = function(_, k)
    error(("No component named %q!"):format(k), 2)
end})