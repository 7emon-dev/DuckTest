local ProgressionConfig = {}

function ProgressionConfig.GetSpeed(level)
	return 50 * (1 - 1.1 ^ -level)
end

function ProgressionConfig.GetXPRequired(level)
	return math.floor(100 * level ^ 1.15)
end

return ProgressionConfig
