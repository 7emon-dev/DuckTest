local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local UpdateDuckRemote = ReplicatedStorage.Remotes.UpdateDuck
local ProgressionConfig = require(ReplicatedStorage.Shared.ProgressionConfig)

local DuckService = {}

local roots = {}
local humanoids = {}
local lastPositions = {}

local PlayerDatas = {}

Players.PlayerAdded:Connect(function(player)
	PlayerDatas[player.UserId] = {
		Speed = {
			Land = 1,
			Water = 1,
			Air = 1,
		},
		XP = {
			Land = 0,
			Water = 0,
			Air = 0,
			Total = 0,
		},
		Level = {
			Land = 1,
			Water = 1,
			Air = 1,
		},
		multiplier = 1,
		-- 1, 2, 5,  25,  50,  100,  250,    500
		-- 0, 3, 15, 100, 500, 2500, 15000, 50000
		trophies = 1,
	}
	player.CharacterAdded:Connect(function(character)
		local root = character:WaitForChild("HumanoidRootPart")
		local humanoid = character:WaitForChild("Humanoid")

		roots[player.UserId] = root
		humanoids[player.UserId] = humanoid

		lastPositions[player.UserId] = root.Position

		for level, value in pairs(PlayerDatas[player.UserId].Level) do
			PlayerDatas[player.UserId].Speed[level] = ProgressionConfig.GetSpeed(value)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	roots[player.UserId] = nil
	humanoids[player.UserId] = nil
	lastPositions[player.UserId] = nil
	PlayerDatas[player.UserId] = nil
end)

UpdateDuckRemote.OnServerEvent:Connect(function(player)
	local ServerData = PlayerDatas[player.UserId]
	UpdateDuckRemote:FireClient(player, ServerData)
end)

function DuckService:AddXP(player, stat, amount)
	local data = PlayerDatas[player.UserId]
	if not data then
		return
	end

	data.XP[stat] += amount
	data.XP.Total += amount

	if data.XP[stat] >= ProgressionConfig.GetXPRequired(data.Level[stat]) then
		data.XP[stat] -= ProgressionConfig.GetXPRequired(data.Level[stat])
		self:LevelUp(player, stat, 1)
	end
	UpdateDuckRemote:FireClient(player, data)
end

function DuckService:AddTrophies(player, amount)
	local data = PlayerDatas[player.UserId]
	if not data then
		return
	end

	data.trophies += amount
end

function DuckService:LevelUp(player, stat, amount)
	local data = PlayerDatas[player.UserId]
	if not data then
		return
	end
	data.Level[stat] += amount
	data.Speed[stat] = ProgressionConfig.GetSpeed(data.Level[stat])
end

function DuckService:ApplyMultiplier(player, multiplier)
	local data = PlayerDatas[player.UserId]
	if not data then
		return
	end

	data.multiplier = multiplier
end

RunService.Heartbeat:Connect(function()
	for userId, root in pairs(roots) do
		local humanoid = humanoids[userId]

		if not humanoid then
			continue
		end

		local delta = root.Position - lastPositions[userId]
		local horizontal = Vector3.new(delta.X, 0, delta.Z)
		local vertical = math.abs(delta.Y)
		local distanceMoved

		lastPositions[userId] = root.Position

		local stat
		local state = humanoid:GetState()

		if humanoid.FloorMaterial == Enum.Material.ForceField then
			stat = "Water"
			distanceMoved = horizontal.Magnitude
		elseif state == Enum.HumanoidStateType.Freefall then
			stat = "Air"
			distanceMoved = vertical
		elseif state == Enum.HumanoidStateType.Running then
			stat = "Land"
			distanceMoved = horizontal.Magnitude
		else
			continue
		end

		local player = Players:GetPlayerByUserId(userId)

		DuckService:AddXP(player, stat, distanceMoved * PlayerDatas[userId].multiplier) -- *1 for normal, 16 for debug
	end
end)

return DuckService
