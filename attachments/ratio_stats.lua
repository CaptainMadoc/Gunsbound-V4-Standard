module = {
	
}

function module:create(attachment)
	local selfAttachment = {} 

	function selfAttachment:refreshStats()
		for i,v in pairs(attachment.stats) do
			if i == "fireSounds" then
				animator.setSoundPool("fireSounds", v)
			elseif gun.stats[i] then
				gun.stats[i] = math.max(gun.stats[i] * v, 0)
			end
		end	
	end

	function selfAttachment:update(dt)
	
	end
	
	function selfAttachment:uninit()
	
	end
	
	return selfAttachment
end
