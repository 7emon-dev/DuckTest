local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local InventoryController = require(script.Parent.InventoryController)

local UIController = {}

local Buttons = {
	HatchButton = function()
		print("Hatch button clicked")
		Remotes.HatchPet:FireServer()
	end,
	InventoryButton = function()
		print("Inventory button clicked")
		InventoryController.DisplayInventory()
	end,
}

function UIController:Init()
	for buttonName, action in pairs(Buttons) do
		local button = gui:WaitForChild(buttonName)
		button.MouseButton1Click:Connect(action)
	end
end

UIController:Init()

return UIController
