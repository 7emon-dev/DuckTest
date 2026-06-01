local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local petsFolder = Workspace:FindFirstChild("Pets")

if not petsFolder then
	petsFolder = Instance.new("Folder")
	petsFolder.Name = "Pets"
	petsFolder.Parent = Workspace
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local root = character:WaitForChild("HumanoidRootPart")
		local duck = ServerStorage.Models.Duck_Land:Clone()

		duck.Parent = character
		duck.CFrame = root.CFrame

		duck.Anchored = false
		duck.Size *= 5

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = root
		weld.Part1 = duck
		weld.Parent = duck
		duck.CanCollide = false
	end)
end)
