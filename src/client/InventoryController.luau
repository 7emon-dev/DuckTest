local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpdateClientInventory = ReplicatedStorage.Remotes.UpdateClientInventory

local InventoryController = {}

local ClientInventory = {}

UpdateClientInventory.OnClientEvent:Connect(function(ServerInventory)
	ClientInventory = ServerInventory
	print("Client inventory updated:", ClientInventory)
end)

function InventoryController:DisplayClientInventory()
	print("Display Client Inventory:", ClientInventory)
end

return InventoryController
