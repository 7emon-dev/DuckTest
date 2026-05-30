local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UpdateDuckRemote = ReplicatedStorage.Remotes.UpdateDuck

local DuckService = {}

local DuckDatas = {}

local roots = {}
local humanoids = {}
local distances = {}
local lastPositions = {}

local DuckDatas = {}

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local root = character:WaitForChild("HumanoidRootPart")
		local humanoid = character:WaitForChild("Humanoid")

		roots[player.UserId] = root
		humanoids[player.UserId] = humanoid

		lastPositions[player.UserId] = root.Position
		distances[player.UserId] = 0

		DuckDatas[player.UserId] = {
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
			Level = 1,
		}
		distances[player.UserId] = {
			Land = 0,
			Water = 0,
			Air = 0,
		}
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	roots[player.UserId] = nil
	humanoids[player.UserId] = nil
	lastPositions[player.UserId] = nil
	distances[player.UserId] = nil
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
	UpdateDuckRemote:FireClient(player, data)
end

function DuckService:LevelUp(player, stat, amount)
	local data = DuckDatas[player.UserId]
	if not data then
		return
	end
	data.Speed[stat] += amount
	UpdateDuckRemote:FireClient(player, data)
end

RunService.Heartbeat:Connect(function(dt)
	for userId, root in pairs(roots) do
		local humanoid = humanoids[userId]

		if not humanoid then
			continue
		end

		local lastPos = lastPositions[userId]

		if not lastPos then
			lastPositions[userId] = root.Position
			continue
		end

		local distanceMoved = (root.Position - lastPos).Magnitude

		lastPositions[userId] = root.Position

		if distanceMoved < 0.1 then
			continue
		end

		local stat
		if humanoid.FloorMaterial == Enum.Material.Water then
			stat = "Water"
		elseif humanoid:GetState() == Enum.HumanoidStateType.Freefall then
			stat = "Air"
		else
			stat = "Land"
		end

		distances[userId][stat] += distanceMoved

		if distances[userId][stat] >= 100 then
			distances[userId][stat] -= 100

			local player = Players:GetPlayerByUserId(userId)

			if player then
				DuckService:LevelUp(player, stat, 1)
				DuckService:AddXP(player, stat, 10)
			end
		end
	end
end)
