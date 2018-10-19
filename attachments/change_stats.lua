module = {
	
}

function module:create(attachmentConfig)
	local selfAttachment = {} 
	
	if attachmentConfig.stats.fireSounds then
		animator.setSoundPool("fireSounds", attachmentConfig.stats.fireSounds)
	end
	
	function selfAttachment:refreshStats()
		attachment:setStats(attachmentConfig.stats)
	end

	function selfAttachment:update(dt)
	
	end
	
	function selfAttachment:uninit()
	
	end
	
	return selfAttachment
end
