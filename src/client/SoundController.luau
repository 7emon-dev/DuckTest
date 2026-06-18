local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local PopSound = ReplicatedStorage.Assets.Sounds:WaitForChild("Pop Sound Effect")

local SoundController = {}

local popData = {
	combo = 0,
	lastCollect = 0,
	lastSoundTime = 0,
	COMBO_DECAY = 50,
	MAX_COMBO = 200,
	SOUND_COOLDOWN = 0.08,
	PITCH_INCREMENT = 0.005,
}

function SoundController:PopSound()
	local now = tick()
	local elapsed = now - popData.lastCollect
	popData.lastCollect = now
	popData.combo -= elapsed * popData.COMBO_DECAY
	popData.combo = math.clamp(popData.combo + 1, 0, popData.MAX_COMBO)
	if now - popData.lastSoundTime < popData.SOUND_COOLDOWN then
		return
	end
	local sound = PopSound:Clone()
	sound.Parent = SoundService

	sound.PlaybackSpeed = 1 + popData.combo * popData.PITCH_INCREMENT
	sound.Volume = 0.01

	sound:Play()
	popData.lastSoundTime = now
	Debris:AddItem(sound, 0.5)
end

function SoundController:Trophy()
	local sound = PopSound:Clone()
	sound.Parent = SoundService

	sound:Play()
end

return SoundController
