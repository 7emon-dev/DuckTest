local Players = game:GetService("Players")

local DuckService = require(script.Parent.DuckService)

local trophyFolder = workspace:WaitForChild("TrophyPads")
local multiplierFolder = workspace:WaitForChild("MultiplierPads")

local spawnLocation = workspace:WaitForChild("SpawnLocation")

local debounce = {}

local function trophyPadTouched(pad, hit)
	local player = Players:GetPlayerFromCharacter(hit.Parent)

	if not player then
		return
	end

	if debounce[player.UserId] then
		return
	end

	debounce[player.UserId] = true
	task.delay(1, function()
		debounce[player.UserId] = nil
	end)

	local amount = pad:GetAttribute("TrophyAmount") or 1
	DuckService:AddTrophies(player, amount)

	local root = hit.Parent:FindFirstChild("HumanoidRootPart")
	if root then
		root.AssemblyLinearVelocity = Vector3.zero
		root.CFrame = spawnLocation.CFrame + Vector3.new(0, 5, 0)
	end
end

local function multiplierPadTouched(pad, hit)
	local player = Players:GetPlayerFromCharacter(hit.Parent)

	if not player then
		return
	end

	if debounce[player.UserId] then
		return
	end

	debounce[player.UserId] = true
	task.delay(1, function()
		debounce[player.UserId] = nil
	end)

	local multiplier = pad:GetAttribute("Multiplier") or 1
	DuckService:ApplyMultiplier(player, multiplier)
end

for _, pad in ipairs(trophyFolder:GetChildren()) do
	if not pad:IsA("BasePart") then
		continue
	end

	pad.Touched:Connect(function(hit)
		trophyPadTouched(pad, hit)
	end)
end

for _, pad in ipairs(multiplierFolder:GetChildren()) do
	if not pad:IsA("BasePart") then
		continue
	end

	pad.Touched:Connect(function(hit)
		multiplierPadTouched(pad, hit)
	end)
end
