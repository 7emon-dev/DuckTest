local TweenService = game:GetService("TweenService")

local hazards = workspace:WaitForChild("Hazards")
local chases = hazards:WaitForChild("Chases")

local HazardService = {}
local activeHazards = {}

function HazardService:StartChase(chase)
	task.spawn(function()
		local data = activeHazards[chase]
		if not data then
			return
		end

		while chase.Parent do
			local tweenInfo = TweenInfo.new(data.speed, Enum.EasingStyle.Linear)
			data.hitbox.CFrame = data.startCF
			local tween = TweenService:Create(data.hitbox, tweenInfo, { CFrame = data.endCF })
			tween:Play()
			tween.Completed:Wait()
			task.wait(data.reload)
		end
	end)
end

function HazardService:SetupChase(chase)
	if activeHazards[chase] then
		return
	end
	local startCF = chase.Start.CFrame
	local endCF = chase.End.CFrame
	local hitbox = chase.Hitbox
	hitbox.CanCollide = false
	hitbox.Anchored = true

	hitbox.Touched:Connect(function(hit)
		local character = hit:FindFirstAncestorOfClass("Model")
		local humanoid = character and character:FindFirstChild("Humanoid")

		if humanoid then
			humanoid.Health = 0
		end
	end)

	activeHazards[chase] = {
		startCF = startCF,
		endCF = endCF,
		hitbox = hitbox,
		speed = chase:GetAttribute("Speed") or 10,
		reload = chase:GetAttribute("ReloadTime") or 2,
	}

	HazardService:StartChase(chase)
end

function HazardService:Init()
	for _, chase in ipairs(chases:GetChildren()) do
		HazardService:SetupChase(chase)
	end
end

return HazardService
