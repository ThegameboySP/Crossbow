local CollectionService = game:GetService("CollectionService")

local SoundPlayer = {}
SoundPlayer.__index = SoundPlayer

function SoundPlayer.new(soundRoot, soundGroup)
    local self = setmetatable({
        _soundGroup = soundGroup;
        _activeSoundsCount = {};
        _soundToDiscriminator = {};
        _queue = {};
        _soundRoot = soundRoot;
        _connection = nil;
    }, SoundPlayer)

    self._connection = CollectionService:GetInstanceRemovedSignal("CrossbowSound"):Connect(function(sound)
        local discriminator = self._soundToDiscriminator[sound]
        self._activeSoundsCount[discriminator] -= 1
        
        if self._activeSoundsCount[discriminator] == 0 then
            self._activeSoundsCount[discriminator] = nil
        end

        self._soundToDiscriminator[sound] = nil
    end)

    return self
end

function SoundPlayer:Destroy()
    self._connection:Disconnect()
end

function SoundPlayer:_queueSound(sound, discriminator, binding, throttle, isForcing)
    local soundsCount = self._activeSoundsCount[discriminator]
    if not isForcing and throttle and soundsCount and soundsCount >= throttle then
        return false
    end

    table.insert(self._queue, table.freeze({
        sound = sound;
        binding = binding;
        discriminator = discriminator;
    }))

    return true
end

function SoundPlayer:queueSound(sound, discriminator, binding,  throttle)
    return self:_queueSound(sound, discriminator or sound, binding, throttle or math.huge, false)
end

function SoundPlayer:forceQueueSound(sound, discriminator, binding)
    return self:_queueSound(sound, discriminator or sound, binding, math.huge, true)
end

function SoundPlayer:getActiveSoundCount(discriminator)
    return self._activeSoundsCount[discriminator] or 0
end

function SoundPlayer:step()
    if self._queue[1] then
        for _, record in ipairs(self._queue) do
            local clone = record.sound:Clone()
            CollectionService:AddTag(clone, "CrossbowSound")
            clone.SoundGroup = self._soundGroup
            self._soundToDiscriminator[clone] = record.discriminator

            self._activeSoundsCount[record.discriminator] = self:getActiveSoundCount(record.discriminator) + 1

            if record.binding == nil then
                clone.Parent = self._soundGroup
                clone:Play()

                clone.Ended:Connect(function()
                    clone.Parent = nil
                end)
            elseif typeof(record.binding) == "Vector3" then
                local attachment = Instance.new("Attachment")
                attachment.Position = record.binding
                clone.Parent = attachment
                attachment.Parent = self._soundRoot
        
                clone:Play()

                clone.Ended:Connect(function()
                    attachment.Parent = nil
                end)
            elseif typeof(record.binding) == "Instance" then
                clone.Parent = record.binding
                clone:Play()

                clone.Ended:Connect(function()
                    clone.Parent = nil
                end)
            end
        end

        table.clear(self._queue)
    end
end

return SoundPlayer