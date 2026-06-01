local ProgressionConfig = {}

function ProgressionConfig.GetSpeed(level)
	return level * 2
end

function ProgressionConfig.GetXPRequired(level)
	return math.floor(100 * level ^ 1.15)
end

return ProgressionConfig
