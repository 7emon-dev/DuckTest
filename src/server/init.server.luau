local Workspace = game:GetService("Workspace")

local petsFolder = Workspace:FindFirstChild("Pets")

if not petsFolder then
	petsFolder = Instance.new("Folder")
	petsFolder.Name = "Pets"
	petsFolder.Parent = Workspace
end
