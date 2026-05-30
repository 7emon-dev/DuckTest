local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local root
local humanoid
local freefall = false

player.CharacterAdded:Connect(function(character)
	root = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
	freefall = false
	humanoid.StateChanged:Connect(function(_, newState)
		freefall = (newState == Enum.HumanoidStateType.Freefall)
	end)
end)

RunService.Heartbeat:Connect(function()
	if not root then
		return
	end
	if freefall then
		local velocity = root.AssemblyLinearVelocity
		if velocity.Y < -10 then
			root.AssemblyLinearVelocity = Vector3.new(velocity.X, -10, velocity.Z)
		end
	end
end)
