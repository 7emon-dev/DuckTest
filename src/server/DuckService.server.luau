local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local UpdateDuckRemote = ReplicatedStorage.Remotes.UpdateDuck
local ProgressionConfig = require(ReplicatedStorage.Shared.ProgressionConfig)

local DuckService = {}

local roots = {}
local humanoids = {}
local lastPositions = {}

local DuckDatas = {}

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local root = character:WaitForChild("HumanoidRootPart")
		local humanoid = character:WaitForChild("Humanoid")

		roots[player.UserId] = root
		humanoids[player.UserId] = humanoid

		lastPositions[player.UserId] = root.Position

		DuckDatas[player.UserId] = {
			Speed = {
				Land = 12,
				Water = 12,
				Air = 12,
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
		}

		for level, value in pairs(DuckDatas[player.UserId].Level) do
			DuckDatas[player.UserId].Speed[level] = ProgressionConfig.GetSpeed(value)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	roots[player.UserId] = nil
	humanoids[player.UserId] = nil
	lastPositions[player.UserId] = nil
	DuckDatas[player.UserId] = nil
end)

UpdateDuckRemote.OnServerEvent:Connect(function(player)
	local ServerData = DuckDatas[player.UserId]
	UpdateDuckRemote:FireClient(player, ServerData)
end)

function DuckService:AddXP(player, stat, amount)
	local data = DuckDatas[player.UserId]
	if not data then
		return
	end

	data.XP[stat] += amount

	if data.XP[stat] >= ProgressionConfig.GetXPRequired(data.Level[stat]) then
		data.XP[stat] -= ProgressionConfig.GetXPRequired(data.Level[stat])
		self:LevelUp(player, stat, 1)
	end
	UpdateDuckRemote:FireClient(player, data)
end

function DuckService:LevelUp(player, stat, amount)
	local data = DuckDatas[player.UserId]
	if not data then
		return
	end
	data.Level[stat] += amount
	data.Speed[stat] = ProgressionConfig.GetSpeed(data.Level[stat])
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
		DuckService:AddXP(player, stat, distanceMoved * 16) -- *1 for normal, 16 for debug
	end
end)
