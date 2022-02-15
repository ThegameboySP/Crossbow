local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local General = require(script.Parent.General)
local Raycaster = require(script.Parent.Raycaster)

local LocalPlayer = Players.LocalPlayer
local IS_SERVER = RunService:IsServer()

local Filters = {}

function Filters.always()
	return true
end

function Filters.never()
	return false
end

function Filters.isTeammate(char1, char2)
	local player1 = Players:GetPlayerFromCharacter(char1)
	if player1 == nil then
		return false
	end

	local player2 = Players:GetPlayerFromCharacter(char2)
	if player2 == nil then
		return false
	end

	return player1.Team == player2.Team
end

function Filters.isValidCharacter(char)
	local hum = char:FindFirstChild("Humanoid")
	if not hum then
		return false
	end

	return hum.Health > 0
end

function Filters.canCollide(part, collisionGroupName)
	return
		part.CanCollide
		and PhysicsService:CollisionGroupsAreCollidable(
			PhysicsService:GetCollisionGroupName(part.CollisionGroupId),
			collisionGroupName or "Default"
		)
end

function Filters.isLocalCharacter(part)
	if IS_SERVER then
		return false
	end

	local char = General.getCharacter(part)
	return 
		char
		and Players:GetPlayerFromCharacter(char) == LocalPlayer
		or false
end

function Filters.isGrounded(part)
	local CF = part.CFrame
	return not not Raycaster.withFilter(
		CF.Position,
		part.Size * -Vector3.yAxis * 0.5 - Vector3.new(0, 0.5, 0),
		nil,
		function(hit)
			return hit.Anchored
		end
	)
end

return Filters