local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UpdateDuckRemote = ReplicatedStorage.Remotes.UpdateDuck

local player = Players.LocalPlayer
local UIController = require(script.Parent.UIController)

local root
local humanoid

local DuckData = nil
local currentMovementState = nil

function UpdateSpeed(state)
	if state == "Air" then
		humanoid.WalkSpeed = DuckData.Speed.Air
	elseif state == "Land" then
		humanoid.WalkSpeed = DuckData.Speed.Land
	elseif state == "Water" then
		humanoid.WalkSpeed = DuckData.Speed.Water
	end
end

UpdateDuckRemote.OnClientEvent:Connect(function(ServerData)
	DuckData = ServerData
	UIController:UpdateUI(DuckData)
	UpdateSpeed(currentMovementState)
	-- print("Duck data updated:", DuckData)
end)

local function setupCharacter(character)
	root = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
	UpdateDuckRemote:FireServer()
end

if player.Character then
	setupCharacter(player.Character)
end

RunService.Heartbeat:Connect(function()
	if not root or not DuckData then
		return
	end

	local newMovementState
	if humanoid.FloorMaterial == Enum.Material.Water then
		newMovementState = "Water"
	elseif humanoid:GetState() == Enum.HumanoidStateType.Freefall then
		local velocity = root.AssemblyLinearVelocity
		if velocity.Y < 0 then
			root.AssemblyLinearVelocity = Vector3.new(velocity.X, -10, velocity.Z)
		end
		newMovementState = "Air"
	elseif humanoid:GetState() == Enum.HumanoidStateType.Running then
		newMovementState = "Land"
	end

	if newMovementState == currentMovementState then
		return
	end

	currentMovementState = newMovementState
	UpdateSpeed(currentMovementState)
end)
