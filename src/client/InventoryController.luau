local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpdateInventory = ReplicatedStorage.Remotes.UpdateInventory

local InventoryController = {}

local ClientInventory = {}

UpdateInventory.OnClientEvent:Connect(function(ServerInventory)
	ClientInventory = ServerInventory
	print("Client inventory updated")
end)

function InventoryController:DisplayInventory()
	print(ClientInventory)
end

return InventoryController
