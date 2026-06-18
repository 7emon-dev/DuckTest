local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local InventoryController = require(script.Parent.InventoryController)
local SoundController = require(script.Parent.SoundController)
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
	ResetButton = function()
		print("Reset button clicked")
		Remotes.Reset:FireServer(player)
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
	text ..= string.format("\nTrophies: %d", DuckData.trophies)
	text ..= string.format("\nMultiplier: %d", DuckData.multiplier)
	gui.StatsLabel.Text = text
end

function UIController:Init()
	local gui = GetGUI()
	for buttonName, action in pairs(Buttons) do
		local button = gui:WaitForChild(buttonName)
		button.MouseButton1Click:Connect(action)
	end
end

local function DisplayTrophyIcon()
	local decal = ReplicatedStorage.Assets.UI.Trophy:Clone()
	local icon = Instance.new("ImageLabel")
	icon.Image = decal.Texture
	icon.Parent = GetGUI()
	icon.Position = UDim2.fromScale(0.5, 0.5)
	icon.Size = UDim2.fromOffset(50, 50)

	icon.ImageTransparency = 1

	TweenService:Create(icon, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		ImageTransparency = 0,
		Position = icon.Position - UDim2.fromOffset(0, 60),
		Size = UDim2.fromOffset(100, 100),
	}):Play()

	task.delay(1, function()
		TweenService:Create(icon, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			ImageTransparency = 1,
		}):Play()
	end)

	task.delay(1.5, function()
		icon:Destroy()
	end)
end

Remotes.PlayTrophy.OnClientEvent:Connect(function()
	SoundController:Trophy()
	DisplayTrophyIcon()
end)

UIController:Init()

return UIController
