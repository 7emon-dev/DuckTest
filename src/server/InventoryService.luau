local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpdateInventory = ReplicatedStorage.Remotes.UpdateInventory
local Players = game:GetService("Players")

local InventoryService = {}

local inventories = {}

function InventoryService:GetInventory(player)
	if not inventories[player.UserId] then
		inventories[player.UserId] = {
			Money = 0,
			Pets = {},
		}
	end

	return inventories[player.UserId]
end

function InventoryService:AddPet(player, petId)
	local inventory = self:GetInventory(player)

	local petData = {
		Id = petId,
		Level = 1,
		XP = 0,
	}

	table.insert(inventory.Pets, petData)

	print("Server inventory updated")
end

function InventoryService:PushInventory(player)
	-- print("Send to Client:", player.Name)
	UpdateInventory:FireClient(player, self:GetInventory(player))
end

Players.PlayerAdded:Connect(function(player)
	InventoryService:PushInventory(player)
end)

return InventoryService
