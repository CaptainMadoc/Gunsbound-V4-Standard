module = {
	
}

function module:create(attachmentConfig)
	local attachment = {} 
	
	if attachmentConfig.stats.fireSounds then
		animator.setSoundPool("fireSounds", attachmentConfig.stats.fireSounds)
	end
	
	function attachment:refreshStats()
		attachmentSystem:setStats(attachmentConfig.stats)
	end
	
	animator.setGlobalTag("magazine","/assetmissing.png")
	
	function attachment:update(dt)
	
	end
	
	function attachment:uninit()
		animator.setGlobalTag("magazine", "mag.png")
	end
	
	return attachment
end
