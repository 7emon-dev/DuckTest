local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpdateClientInventory = ReplicatedStorage.Remotes.UpdateClientInventory

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

	print(player.Name, "received pet:", petId)
end

function InventoryService:UpdateClient(player)
	UpdateClientInventory:FireClient(player, self:GetInventory(player))
end

return InventoryService
