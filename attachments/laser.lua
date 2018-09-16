module = {
	
}

function module:create(config, name)
	local selfAttachment = {}
	
	lasermanager:add(attachment.config[name].attachPart, attachment.config[name].gunTag, attachment.config[name].gunTagEnd, config.laserColor)

	function selfAttachment:refreshStats()
		local gottenStats = attachment:getStats()

		gottenStats.movingInaccuracy = gottenStats.movingInaccuracy / 2
		gottenStats.standingInaccuracy = gottenStats.standingInaccuracy / 2
		gottenStats.crouchInaccuracyMultiplier = gottenStats.crouchInaccuracyMultiplier / 2
		
		attachment:setStats(gottenStats)
	end

	function selfAttachment:uninit()
	
	end
	
	return selfAttachment
end
