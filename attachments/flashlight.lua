module = {
	
}

function module:create(config, name)
	local selfAttachment = {}
	
	flashlight:add(attachment.config[name].attachPart, attachment.config[name].gunTag, attachment.config[name].gunTagEnd, config.lightColor)
	
	function selfAttachment:uninit()
	
	end
	
	return selfAttachment
end
