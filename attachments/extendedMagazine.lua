module = {
	
}

function module:create(attachment)
	local newClass = {} 
	
	if attachmentConfig.stats.fireSounds then
		animator.setSoundPool("fireSounds", attachmentConfig.stats.fireSounds)
	end
	attachment:setStats(attachmentConfig.stats)
	
	animator.setGlobalTag("magazine","/assetmissing.png")
	
	function newClass:update(dt)
	
	end
	
	function newClass:uninit()
		animator.setGlobalTag("magazine", "mag.png")
	end
	
	return newClass
end
