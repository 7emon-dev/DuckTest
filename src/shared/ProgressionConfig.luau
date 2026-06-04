local ProgressionConfig = {}

function ProgressionConfig.GetSpeed(level)
	-- return 100 * (1 - 0.97 ^ level)
	return (level * 2) + 10
end

function ProgressionConfig.GetXPRequired(level)
	return math.floor(100 * 1.15 ^ (level - 1))
end

return ProgressionConfig
