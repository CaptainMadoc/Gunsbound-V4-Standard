module = {
	
}

function module:create(attachment)
	local newClass = {} 
	
	if attachmentConfig.stats.fireSounds then
		animator.setSoundPool("fireSounds", attachmentConfig.stats.fireSounds)
	end
	attachment:setStats(attachmentConfig.stats)
	
	function newClass:update(dt)
	
	end
	
	function newClass:uninit()
	
	end
	
	return newClass
end
