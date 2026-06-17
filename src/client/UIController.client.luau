local trophyFolder = workspace:WaitForChild("TrophyPads")
local multiplierFolder = workspace:WaitForChild("MultiplierPads")

local function createBillboard(part, text)
	print("Creating billboard for", part.Name)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(120, 50)
	gui.StudsOffset = Vector3.new(0, 4, 0)
	gui.AlwaysOnTop = true
	gui.Parent = part
	gui.MaxDistance = 100

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.TextSize = 20
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.Parent = gui
end

local function setupPad(part)
	local rewardType = part.Parent.Name
	if rewardType == "TrophyPads" then
		local amount = part:GetAttribute("TrophyAmount")
		createBillboard(part, "+" .. amount .. " Trophies")
	elseif rewardType == "MultiplierPads" then
		local mult = part:GetAttribute("Multiplier")
		local cost = part:GetAttribute("Cost")
		createBillboard(part, "x" .. mult .. " Mult\nCost: " .. cost)
	end
end

local function registerPad(pad)
	if pad:IsA("BasePart") then
		setupPad(pad)
	end
end

for _, pad in ipairs(multiplierFolder:GetChildren()) do
	registerPad(pad)
end
for _, pad in ipairs(trophyFolder:GetChildren()) do
	registerPad(pad)
end
multiplierFolder.ChildAdded:Connect(registerPad)
trophyFolder.ChildAdded:Connect(registerPad)
