local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UpdateDuckRemote = ReplicatedStorage.Remotes.UpdateDuck

local player = Players.LocalPlayer
local HUDController = require(script.Parent.HUDController)

local root
local humanoid

local DuckData = nil
local currentMovementState = nil

function UpdateSpeed(state)
	local newSpeed
	local velocity = root.AssemblyLinearVelocity
	if state == "Air" then
		newSpeed = DuckData.Speed.Air
		root.AssemblyLinearVelocity =
			Vector3.new(math.min(velocity.x, newSpeed), velocity.Y, math.min(velocity.z, newSpeed))
		humanoid.WalkSpeed = newSpeed
	elseif state == "Land" then
		newSpeed = DuckData.Speed.Land
		root.AssemblyLinearVelocity =
			Vector3.new(math.min(velocity.x, newSpeed), velocity.Y, math.min(velocity.z, newSpeed))
		humanoid.WalkSpeed = newSpeed
	elseif state == "Water" then
		newSpeed = DuckData.Speed.Water
		root.AssemblyLinearVelocity =
			Vector3.new(math.min(velocity.x, newSpeed), velocity.Y, math.min(velocity.z, newSpeed))
		humanoid.WalkSpeed = newSpeed
	end
end

UpdateDuckRemote.OnClientEvent:Connect(function(ServerData)
	DuckData = ServerData
	HUDController:UpdateUI(DuckData)
	UpdateSpeed(currentMovementState)
	-- print("Duck data updated:", DuckData)
end)

local function setupCharacter(character)
	root = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	UpdateDuckRemote:FireServer()
end

if player.Character then
	setupCharacter(player.Character)
end

player.CharacterAdded:Connect(setupCharacter)

RunService.Heartbeat:Connect(function()
	if not root or not DuckData then
		return
	end

	local newMovementState

	if humanoid.FloorMaterial == Enum.Material.ForceField then
		newMovementState = "Water"
	elseif humanoid:GetState() == Enum.HumanoidStateType.Freefall then
		local velocity = root.AssemblyLinearVelocity
		if velocity.Y < 0 then
			root.AssemblyLinearVelocity = Vector3.new(velocity.X, math.max(velocity.Y, -10), velocity.Z)
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
