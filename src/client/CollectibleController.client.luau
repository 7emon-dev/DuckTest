local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectibleModels = ReplicatedStorage.Assets.Collectibles

local player = Players.LocalPlayer
local collectibleSpawns = workspace:WaitForChild("CollectibleSpawns")
local collectibles = workspace:WaitForChild("Collectibles")

local CollectibleConfig = {
	Land = {
		Model = CollectibleModels.Seed,
		RespawnTime = 5,
	},
	Water = {
		Model = CollectibleModels.Bread,
		RespawnTime = 5,
	},
}

local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

if player.Character then
	root = player.Character:WaitForChild("HumanoidRootPart")
end

player.CharacterAdded:Connect(function()
	character = player.Character
	root = character:WaitForChild("HumanoidRootPart")
end)

local function getRandomCFrame(collectibleType, zone)
	local size = zone.Size
	local cf = zone.CFrame

	local x = (math.random() - 0.5) * size.X
	local y = 1
	local z = (math.random() - 0.5) * size.Z
	local position = (cf * CFrame.new(x, y, z)).Position
	local rotation
	if collectibleType == "Land" then
		rotation = CFrame.Angles(0, math.rad(math.random(0, 360)), 0)
	elseif collectibleType == "Water" then
		rotation = CFrame.Angles(math.rad(90), 0, math.rad(math.random(0, 360)))
	end
	return CFrame.new(position) * rotation
end

local function createCollectible(collectibleType, cf)
	local model
	if collectibleType == "Land" then
		model = CollectibleConfig.Land.Model:Clone()
	elseif collectibleType == "Water" then
		model = CollectibleConfig.Water.Model:Clone()
	else
		return
	end
	model:SetAttribute("CollectibleType", collectibleType)
	model:PivotTo(cf)
	model.Parent = collectibles
	model.Anchored = true
	model.CanCollide = false

	return model
end

for _, collectibleType in ipairs(collectibleSpawns:GetChildren()) do
	for _, zone in ipairs(collectibleType:GetChildren()) do
		if zone:IsA("BasePart") then
			local density = zone:GetAttribute("SeedDensity") or 500
			for _ = 1, density do
				createCollectible(collectibleType.Name, getRandomCFrame(collectibleType.Name, zone))
			end
		end
	end
end

local function respawnCollectible(collectibleType, cf, respawnTime)
	task.delay(respawnTime, function()
		createCollectible(collectibleType, cf)
	end)
end

local function collectCollectible(collectible)
	if not collectible.Parent then
		return
	end
	local collectibleType = collectible:GetAttribute("CollectibleType")

	collectible:Destroy()
	respawnCollectible(collectibleType, collectible:GetPivot(), 5)
end

local MAGNET_RADIUS = 8
local MAGNET_SPEED = 3

local function magnetPull(collectible, dt)
	local direction = root.Position - collectible.Position
	local distance = direction.Magnitude
	local strength = 1 + (MAGNET_RADIUS - distance)
	local moveAmount = MAGNET_SPEED * strength * dt

	collectible.Position += direction.Unit * math.min(
		moveAmount * math.max(MAGNET_SPEED, root.AssemblyLinearVelocity.Magnitude / 10),
		distance
	)
end

RunService.RenderStepped:Connect(function(dt)
	if not root then
		return
	end

	for _, collectible in ipairs(collectibles:GetChildren()) do
		if not collectible:IsA("BasePart") then
			continue
		end

		local distance = (root.Position - collectible.Position).Magnitude

		if distance <= 2 then
			collectCollectible(collectible)
		elseif distance <= MAGNET_RADIUS then
			magnetPull(collectible, dt)
		end
	end
end)
