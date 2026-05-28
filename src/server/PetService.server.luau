local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local HatchPet = ReplicatedStorage.Remotes.HatchPet
local InventoryService = require(script.Parent.InventoryService)

local PetService = {}

local function getPlayerFolder(player)
	local petsFolder = Workspace:WaitForChild("Pets")
	local playerFolder = petsFolder:FindFirstChild(tostring(player.UserId))

	if not playerFolder then
		playerFolder = Instance.new("Folder")
		playerFolder.Name = tostring(player.UserId)
		playerFolder.Parent = petsFolder
	end

	return playerFolder
end

-- Server side for multiplayer synchronisation
function PetService:SpawnPet(player)
	local character = player.Character
	if not character then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local folder = getPlayerFolder(player)

	local pet = Instance.new("WedgePart")
	pet.Size = Vector3.new(2, 2, 2)
	pet.Position = root.Position + Vector3.new(0, 0, -5)
	pet.Anchored = false

	pet:SetAttribute("OwnerUserId", player.UserId)

	pet.Parent = folder
end

HatchPet.OnServerEvent:Connect(function(player)
	PetService:SpawnPet(player)
	InventoryService:AddPet(player, "BasicPet")
	InventoryService:PushInventory(player)
end)
