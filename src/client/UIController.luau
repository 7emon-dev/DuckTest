local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local InventoryController = require(script.Parent.InventoryController)
local ProgressionConfig = require(ReplicatedStorage.Shared.ProgressionConfig)

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

local function GetGUI()
	local playerGui = player:WaitForChild("PlayerGui")
	return playerGui:WaitForChild("ScreenGui")
end

function UIController:UpdateUI(DuckData)
	if not DuckData then
		return
	end

	local gui = GetGUI()

	local text = ""

	for _, stat in ipairs({ "Land", "Water", "Air" }) do
		local level = DuckData.Level[stat]
		local xp = DuckData.XP[stat]
		local speed = DuckData.Speed[stat]

		local xpRequired = ProgressionConfig.GetXPRequired(level)

		text ..= string.format("%s: | Lv: %d | XP: %.0f/%d | Speed: %.1f\n", stat, level, xp, xpRequired, speed)
	end

	text ..= string.format("\nTotal XP: %.0f", DuckData.XP.Total)

	gui.StatsLabel.Text = text
end

function UIController:Init()
	local gui = GetGUI()
	for buttonName, action in pairs(Buttons) do
		local button = gui:WaitForChild(buttonName)
		button.MouseButton1Click:Connect(action)
	end
end

UIController:Init()

return UIController
