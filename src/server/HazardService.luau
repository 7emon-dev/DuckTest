local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local hazards = workspace:WaitForChild("Hazards")
local chases = hazards:WaitForChild("Chases")
local spinners = hazards:WaitForChild("Arms")
local doors = hazards:WaitForChild("Doors")
local platforms = hazards:WaitForChild("Platforms")

local HazardService = {}
local activeChases = {}
local activeSpinners = {}
local activeDoors = {}
local activePlatforms = {}

local function hitPlayer(hit)
	local character = hit:FindFirstAncestorOfClass("Model")
	local humanoid = character and character:FindFirstChild("Humanoid")

	if humanoid then
		humanoid.Health = 0
	end
end

function HazardService:StartChase(chase)
	task.spawn(function()
		local data = activeChases[chase]
		if not data then
			return
		end

		while chase.Parent do
			data.hitbox.CFrame = data.startCF
			local distance = (data.endCF.Position - data.startCF.Position).Magnitude
			local duration = distance / data.speed
			local tween = TweenService:Create(
				data.hitbox,
				TweenInfo.new(duration, Enum.EasingStyle.Linear),
				{ CFrame = data.endCF }
			)
			task.wait(data.reload)
			tween:Play()
			tween.Completed:Wait()
			task.wait(data.reload / 2)
		end
	end)
end

function HazardService:StartDoor(door)
	task.spawn(function()
		local data = activeDoors[door]
		if not data then
			return
		end

		if data.isBusy then
			return
		end

		data.isBusy = true

		data.hitbox.CFrame = data.startCF
		local distance = (data.endCF.Position - data.startCF.Position).Magnitude
		local duration = distance / data.speed
		local tween =
			TweenService:Create(data.hitbox, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = data.endCF })

		tween:Play()
		tween.Completed:Wait()
		data.isBusy = false
	end)
end

function HazardService:StartPlatform(platform)
	task.spawn(function()
		local data = activePlatforms[platform]

		if not data then
			return
		end

		if data.isBusy then
			return
		end

		data.isBusy = true

		task.delay(0.5, function()
			platform.Hitbox.Anchored = false
			task.wait(1.5)
			platform.Hitbox.Anchored = true
		end)

		task.delay(data.reload, function()
			if platform.Hitbox then
				platform.Hitbox.Anchored = true
				platform.Hitbox.AssemblyLinearVelocity = Vector3.zero
				platform.Hitbox.AssemblyAngularVelocity = Vector3.zero
				platform.Hitbox.CFrame = data.startCF
			end
			data.isBusy = false
		end)
	end)
end

function HazardService:InitChase(chase)
	if activeChases[chase] then
		return
	end
	chase.Hitbox.Touched:Connect(function(hit)
		hitPlayer(hit)
	end)

	chase.Hitbox.CanCollide = false
	chase.Hitbox.Anchored = true
	chase.Start.Transparency = 1
	chase.End.Transparency = 1

	activeChases[chase] = {
		startCF = chase.Start.CFrame,
		endCF = chase.End.CFrame,
		hitbox = chase.Hitbox,
		speed = chase:GetAttribute("Speed") or 10,
		reload = chase:GetAttribute("ReloadTime") or 2,
	}

	HazardService:StartChase(chase)
end

function HazardService:InitSpinner(spinner)
	if activeSpinners[spinner] then
		return
	end
	spinner.Hitbox.Touched:Connect(function(hit)
		hitPlayer(hit)
	end)

	local pivot = spinner:FindFirstChild("Pivot")

	local offset
	if pivot then
		offset = spinner.Pivot.CFrame:ToObjectSpace(spinner.Hitbox.CFrame)
		pivot.Anchored = true
		pivot.CanCollide = false
	end

	spinner.Hitbox.CanCollide = false
	spinner.Hitbox.Anchored = true

	activeSpinners[spinner] = {
		startCF = spinner.Hitbox.CFrame,
		hitbox = spinner.Hitbox,
		pivot = pivot,
		offset = offset,
		speed = spinner:GetAttribute("RotationSpeed") or 90,
		angle = 0,
	}
end

function HazardService:InitDoor(door)
	if activeDoors[door] then
		return
	end

	door.Hitbox.Anchored = true
	door.Button.Anchored = true
	door.Start.Anchored = true
	door.End.Anchored = true
	door.Start.CanCollide = false
	door.End.CanCollide = false

	door.Start.Transparency = 1
	door.End.Transparency = 1

	door.Hitbox.CFrame = door.End.CFrame

	door.Button.Touched:Connect(function()
		HazardService:StartDoor(door)
	end)

	activeDoors[door] = {
		startCF = door.Start.CFrame,
		endCF = door.End.CFrame,
		hitbox = door.Hitbox,
		button = door.Button,
		speed = door:GetAttribute("Speed"),
		isBusy = false,
	}
end

function HazardService:InitPlatform(platform)
	if activePlatforms[platform] then
		return
	end

	platform.Hitbox.Anchored = true
	platform.Hitbox.CanCollide = true

	platform.Hitbox.Touched:Connect(function()
		HazardService:StartPlatform(platform)
	end)

	activePlatforms[platform] = {
		startCF = platform.Hitbox.CFrame,
		hitbox = platform.Hitbox,
		reload = platform:GetAttribute("ReloadTime") or 5,
		isBusy = false,
	}
end

RunService.Heartbeat:Connect(function(dt)
	for _, spinner in pairs(activeSpinners) do
		spinner.angle = (spinner.angle + spinner.speed * dt) % 360
		local rotation = CFrame.Angles(0, math.rad(spinner.angle), 0)

		if spinner.pivot then
			spinner.hitbox.CFrame = spinner.pivot.CFrame * rotation * spinner.offset
		else
			spinner.hitbox.CFrame = spinner.startCF * rotation
		end
	end
end)

function HazardService:Init()
	for _, chase in ipairs(chases:GetChildren()) do
		HazardService:InitChase(chase)
	end
	for _, spinner in ipairs(spinners:GetChildren()) do
		HazardService:InitSpinner(spinner)
	end
	for _, door in ipairs(doors:GetChildren()) do
		HazardService:InitDoor(door)
	end
	for _, platform in ipairs(platforms:GetChildren()) do
		HazardService:InitPlatform(platform)
	end
end

return HazardService
