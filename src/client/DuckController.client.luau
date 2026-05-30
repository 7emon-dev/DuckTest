local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpdateDuckRemote = ReplicatedStorage.Remotes.UpdateDuck

local player = Players.LocalPlayer

local root
local humanoid

local DuckData = nil
local currentMovementState = nil

local function RequestDuckUpdate()
	UpdateDuckRemote:FireServer()
end

UpdateDuckRemote.OnClientEvent:Connect(function(ServerData)
	DuckData = ServerData
	print("Duck data updated:", DuckData)
end)

player.CharacterAdded:Connect(function(character)
	root = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
	RequestDuckUpdate()
end)

RunService.Heartbeat:Connect(function()
	if not root or not DuckData then
		return
	end

	local newMovementState
	if humanoid.FloorMaterial == Enum.Material.Water then
		newMovementState = "Water"
	elseif humanoid:GetState() == Enum.HumanoidStateType.Freefall then
		local velocity = root.AssemblyLinearVelocity
		if velocity.Y < -10 then
			root.AssemblyLinearVelocity = Vector3.new(velocity.X, -10, velocity.Z)
		end
		newMovementState = "Air"
	else
		newMovementState = "Land"
	end

	if newMovementState == currentMovementState then
		return
	end

	currentMovementState = newMovementState

	if newMovementState == "Air" then
		humanoid.WalkSpeed = DuckData.Speed.Air
	elseif newMovementState == "Land" then
		humanoid.WalkSpeed = DuckData.Speed.Land
	elseif newMovementState == "Water" then
		humanoid.WalkSpeed = DuckData.Speed.Water
	end
end)
