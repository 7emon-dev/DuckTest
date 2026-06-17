local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local CollectibleModels = ReplicatedStorage.Assets.Collectibles
local PopSound = ReplicatedStorage.Assets.Sounds:WaitForChild("Pop Sound Effect")

local player = Players.LocalPlayer
local collectibleSpawns = workspace:WaitForChild("CollectibleSpawns")
local collectibles = workspace:WaitForChild("Collectibles")

local CollectibleConfig = {
	Land = {
		Model = CollectibleModels.Seed,
	},
	Water = {
		Model = CollectibleModels.Bread,
	},
}

-- inactive pool
local objectPool = {
	Land = {}, -- seeds
	Water = {}, -- bread
}

-- active pool, seeds/bread
local activePool = {}

local MAGNET_RADIUS = 8
local MAGNET_SPEED = 3

local combo = 0
local lastCollect = 0
local lastSoundTime = 0
local COMBO_DECAY = 50
local MAX_COMBO = 200
local SOUND_COOLDOWN = 0.08
local PITCH_INCREMENT = 0.005

local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

if player.Character then
	root = player.Character:WaitForChild("HumanoidRootPart")
end

player.CharacterAdded:Connect(function()
	character = player.Character
	root = character:WaitForChild("HumanoidRootPart")
end)

local function playPopSound()
	local now = tick()
	local elapsed = now - lastCollect
	lastCollect = now
	combo -= elapsed * COMBO_DECAY
	combo = math.clamp(combo + 1, 0, MAX_COMBO)
	if now - lastSoundTime < SOUND_COOLDOWN then
		return
	end
	local sound = PopSound:Clone()
	sound.Parent = SoundService

	sound.PlaybackSpeed = 1 + combo * PITCH_INCREMENT

	sound:Play()
	lastSoundTime = now
	Debris:AddItem(sound, 0.5)
end

local function createPool(collectibleType, poolSize)
	local pool = objectPool[collectibleType]
	for _ = 1, poolSize do
		local gameObj = CollectibleConfig[collectibleType].Model:Clone()
		gameObj.Parent = collectibles
		gameObj.Anchored = true
		gameObj.CanCollide = false
		gameObj.Transparency = 1
		table.insert(pool, { instance = gameObj, active = false, type = collectibleType, zone = nil })
	end
end

for collectibleType, _ in pairs(objectPool) do
	createPool(collectibleType, 1000)
end

local function getPool(collectibleType)
	local pool = objectPool[collectibleType]
	for _, obj in ipairs(pool) do
		if not obj.active then
			obj.active = true
			return obj
		end
	end
	return
end

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

local function spawnCollectible(collectibleType, zone)
	local obj = getPool(collectibleType)
	if not obj then
		return
	end

	local collectible = obj.instance
	obj.zone = zone
	obj.active = true

	collectible.CFrame = getRandomCFrame(collectibleType, zone)
	collectible.Transparency = 0

	activePool[collectible] = obj
	return
end

for _, collectibleType in ipairs(collectibleSpawns:GetChildren()) do
	for _, zone in ipairs(collectibleType:GetChildren()) do
		if zone:IsA("BasePart") then
			local density = zone:GetAttribute("SeedDensity") or 500
			for _ = 1, density do
				spawnCollectible(collectibleType.Name, zone)
			end
		end
	end
end

local function collectCollectible(collectible)
	if not collectible.Parent then
		return
	end
	local obj = activePool[collectible]
	if not obj then
		return
	end
	obj.active = false
	collectible.Transparency = 1
	activePool[collectible] = nil

	playPopSound()
	spawnCollectible(obj.type, obj.zone)
end

local function magnetPull(collectible, dt)
	local direction = root.Position - collectible.Position
	local distance = direction.Magnitude
	if distance <= 2 then
		return
	end
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
