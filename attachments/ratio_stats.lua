module = {
	
}

function module:create(config)
	local selfAttachment = {} 

	function selfAttachment:refreshStats()
		local gottenStats = attachment:getStats()

		for i,v in pairs(config.stats) do
			if i == "fireSounds" then
				animator.setSoundPool("fireSounds", v)
			elseif gottenStats[i] then
				gottenStats[i] = math.max(gottenStats[i] * v, 0)
			end
		end	
		
		attachment:setStats(gottenStats)
	end

	function selfAttachment:update(dt)
	
	end
	
	function selfAttachment:uninit()
	
	end
	
	return selfAttachment
end
