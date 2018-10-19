--This is a script used by default.
--You can use this as reference if you want to make a custom type weapon.

main = {
    fireQueued = 0,
    reloadLoop = false,
    semifired = false,
    charge = false,
    charged = false
}

--Callbacks 

--this should be his initial startup
function main:init()
	animation:addEvent("reload_loop", function() self.reloadLoop = true end)
    animation:addEvent("reloadLoop", function() self.reloadLoop = true end)
    datamanager:load("chargedTime")
    datamanager:load("chargedGunStats")

    --initial weapon animation
    self:animate("draw")
end

--this is called when a firemode is fired
function main:activate(fireMode, shiftHeld)
    if fireMode == "alt" and not shiftHeld then --this is for special binded attachments
        attachment:triggerSpecial()
    elseif fireMode == "alt" and shiftHeld then --this is for switching firemodes
        gun:switchFireModes()
    end
end

--every ticks (frames)
function main:update(dt, fireMode, shiftHeld, moves)
    if not self.reloadLoop then --makes sure that our frontend script is not busy reloading shells
        self:updateAutoReload()
        self:updateFire(fireMode) 
        self:updateQueuedFire(fireMode) 
        self:updateSpecial(shiftHeld, moves.up)
    else
        if not animation:isAnyPlaying() then --end reload
            if not magazine:playerHasAmmo() or magazine:count() == magazine.size then
                self.reloadLoop = false
                self:animate(data.gunAnimations["reloadEnd"])
            else
                self:animate(data.gunAnimations["reloadLoop"])
            end
        end
    end
end

--this is after init (next frame)
--function main:lateinit() end

--this is called when the lua state is being destroyed
--function main:uninit() end


--OTHER FUNCTIONS

function main:initLocalUI()

end

--We made this so we dont deal with manually shoot + _dry animations
function main:animate(type,noprefix)
    if not noprefix and (gun:chamberDry() and (not gun.hasToLoad and not data.bypassShellEject)) then
		animation:play(data.gunAnimations[type.."_dry"] or data.gunAnimations[type] or type.."_dry")
	else
		animation:play(data.gunAnimations[type] or type)
    end
end
--We made this so we dont deal with manually shoot + _dry animations
function main:unAnimate(type,noprefix)
    if not noprefix and (gun:chamberDry() and (not gun.hasToLoad and not data.bypassShellEject)) then
		animation:skip(data.gunAnimations[type.."_dry"] or data.gunAnimations[type] or type.."_dry")
	else
		animation:skip(data.gunAnimations[type] or type)
    end
end

function main:isAnimate(type)
    return animation:isPlaying(data.gunAnimations[type]) or animation:isPlaying(data.gunAnimations[type.."_dry"]) or animation:isPlaying(type.."_dry")
end

--Fire implementation
function main:fire(overrideStats)
    if not animation:isAnyPlaying() or animation:isPlaying({data.gunAnimations["shoot"], data.gunAnimations["shoot_dry"]}) then
        local status = gun:fire(overrideStats)
        if status then
            self:animate("shoot")
        else
            self:animate("shoot_null", true)
        end
    end
end

--Specials like reload or lever switches stuff and things
function main:updateSpecial(shift, up)
    if shift and up and not animation:isAnyPlaying() then
        self:animate("reload")
    end
    if not shift and up and not animation:isAnyPlaying() then
        self:animate("cock")
    end
end

function main:percentDamage(a,b,r)
    return a + (b - a) * r
end

--we use this for deal with gun common firemodes.
function main:updateFire(firemode)
    if firemode == "primary" and gun:ready() and not self.charge then --init charge
        self.charge = 0
        self:animate("charge")
        if animator.hasSound("charge") then
            animator.playSound("charge")
        end
    elseif firemode == "primary" and gun:ready() and self.charge < data.chargedTime then --charging loop
        self.charge = math.max(math.min(updateInfo.dt + self.charge, data.chargedTime), 0)

        if not self:isAnimate("charge_loop") and not self:isAnimate("charge") then

            self:animate("charge_loop")

            if animator.hasSound("charge") then
                animator.stopAllSounds("charge")
            end

            if animator.hasSound("charging") then
                animator.stopAllSounds("charging")
                animator.playSound("charging")
            end

        end

    elseif firemode == "primary" and self.charge == data.chargedTime and not self.charged then --init charged
        if self:isAnimate("charge_loop") then
            self:unAnimate("charge_loop")
        end

        if animator.hasSound("charging") then
            animator.stopAllSounds("charging")
        end
        
        if animator.hasSound("charged") then
            animator.playSound("charged")
        end

        self:animate("charged")
        self.charged = true
    elseif firemode == "primary" and self.charge == data.chargedTime and self.charged then -- charged
        --just empty
    elseif firemode ~= "primary" and self.charge then --fire charge

        if self:isAnimate("charge") then
            self:unAnimate("charge")
        end

        if self:isAnimate("charge_loop") then
            self:unAnimate("charge_loop")
        end

        if self:isAnimate("charged") then
            self:unAnimate("charged")
        end

        self.charged = false

        if self.charge == 0 then

        else
            --fire queue
            if gun:fireMode() == "burst" then
                self.fireQueued = data.gunStats.burst or 3
            else
                self.fireQueued = 1
            end
            -- original stats -> charged Stats Ratio
            self.chargeRatio = self.charge / data.chargedTime
        end
        self.charge = false
    end
end

--returns a gunStat
function main:chargedStatsRatio(gunstats, chargedstats, ratio)
    local finalStats = {}
    for i,v in pairs(gunstats) do
        if type(chargedstats[i]) == "number" then --float
            finalStats[i] = v + (chargedstats[i] - v) * ratio
        elseif type(chargedstats[i]) == "table" and #chargedstats[i] == 2 and type(v) == "table" and #v == 2 then --vec2 why
            finalStats[i] = {}
            finalStats[i][1] = v[1] + (chargedstats[i][1] - v[1]) * ratio
            finalStats[i][2] = v[2] + (chargedstats[i][2] - v[2]) * ratio
        else
            finalStats[i] = v
        end
    end

    return finalStats
end

-- we're using this for calculting changes from the attachment stats
function main:statsAdd(stats, statsadd) 
    if not statsadd then statsadd = {} end
    local ret = {}
    for i,v in pairs(stats or {}) do
        if type(statsadd[i]) == "number" then
            ret[i] = v + statsadd[i]
        elseif type(statsadd[i]) == "table" and #statsadd[i] == 2 and type(v) == "table" and #v == 2 then
            ret[i] = {}
            ret[i][1] = v[1] + statsadd[i][1]
            ret[i][2] = v[2] + statsadd[i][2]
        else
            ret[i] = v
        end
    end
    return ret
end

 -- our queued burst fires
function main:updateQueuedFire()

    local gunFireMode = gun:fireMode() -- we get his firemode

    if self.fireQueued > 0 and gun:ready() and not gun:chamberDry() then
        local fireStatus = self:fire(self:chargedStatsRatio(data.gunStats, self:statsAdd(data.chargedGunStats, attachment), self.chargeRatio))

        if magazine:count() == 0 then -- if empty, we cancel burst
            self.fireQueued = 0
        else
            self.fireQueued = self.fireQueued - 1
        end

        if self.fireQueued == 0 then -- queue finished reset
            gun.cooldown = gun:rpm()
            self.chargeRatio = 0
        end
    end
end

--smart automatic reload 
function main:updateAutoReload()
    if gun:ready() then
        if (gun:chamberDry() or (data.gunLoad and data.gunLoad.parameters.fired)) and magazine:count() == 0 and magazine:playerHasAmmo() and  not animation:isAnyPlaying() then
            self:animate("reload")
        elseif gun:chamberDry() and magazine:count() > 0 and not animation:isAnyPlaying() then
            self:animate("cock")
        end
    end
end