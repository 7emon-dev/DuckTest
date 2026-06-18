local DataStoreService = game:GetService("DataStoreService")
local PlayerStore = DataStoreService:GetDataStore("PlayerData_v1")

local DataService = {}

local DefaultData = {
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
	multiplier = 1,
	-- 1, 2, 5,  25,  50,  100,  250,    500
	-- 0, 3, 15, 100, 500, 2500, 15000, 50000
	trophies = 0,
}

local function deepClone(original)
	local clone = table.clone(original)

	for key, value in original do
		if type(value) == "table" then
			clone[key] = deepClone(value)
		end
	end

	return clone
end

function DataService:LoadPlayer(player)
	local success, data = pcall(function()
		return PlayerStore:GetAsync(player.UserId)
	end)

	if success and data then
		return data
	end

	return deepClone(DefaultData)
end

function DataService:SavePlayer(player, data)
	local success, err = pcall(function()
		PlayerStore:SetAsync(player.UserId, data)
	end)

	if not success then
		warn(err)
	end
end

return DataService
