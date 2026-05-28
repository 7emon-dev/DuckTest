local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local petsFolder = Workspace:WaitForChild("Pets")

local roots = {}

RunService.RenderStepped:Connect(function()
	for _, player in ipairs(Players:GetPlayers()) do
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")

		if root then
			roots[player.UserId] = root
		end
	end
	for _, playerFolder in ipairs(petsFolder:GetChildren()) do
		local root = roots[tonumber(playerFolder.Name)]
		if root then
			for _, pet in ipairs(playerFolder:GetChildren()) do
				local target = root.CFrame * CFrame.new(2, -2, 5)
				local lookAt = root.Position + root.CFrame.LookVector * 10
				pet.CFrame = pet.CFrame:Lerp(CFrame.new(target.Position, lookAt), 0.1)
			end
		end
	end
end)
