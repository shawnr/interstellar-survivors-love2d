-- VFX Manager
-- Centralized visual effects: shake, flash, particles, transitions, announcements

VFXManager = {
    -- Screen shake
    shakeX = 0,
    shakeY = 0,
    shakeDuration = 0,
    shakeIntensity = 0,
    shakeTimer = 0,

    -- Hit flashes (brief white circle at hit position)
    hitFlashes = {},

    -- Tool fire flashes (expanding ring on tool fire)
    toolFlashes = {},

    -- Death effects (expanding ring at mob death)
    deathEffects = {},

    -- Floating text ("+N RP" rising text)
    floatingTexts = {},

    -- Screen transition (fade to/from black)
    transition = {
        active = false,
        alpha = 0,
        speed = 0,
        phase = "none",  -- "fade_out" (to black) | "fade_in" (from black) | "none"
        onMidpoint = nil,
        onComplete = nil,
        midpointFired = false,
        fadeInSpeed = 0,
    },

    -- Wave announcement
    waveAnnouncement = {
        active = false,
        text = "",
        timer = 0,
        duration = 2.0,
    },

    -- Boss warning
    bossWarning = {
        active = false,
        timer = 0,
        duration = 2.0,
        flashTimer = 0,
        onComplete = nil,
    },

    -- Station destruction sequence
    destructionSequence = {
        active = false,
        timer = 0,
        phase = 0,
        x = 0,
        y = 0,
        rings = {},
        onComplete = nil,
    },

    -- Boss defeat celebration
    defeatCelebration = {
        active = false,
        timer = 0,
        phase = 0,
        onComplete = nil,
    },

    -- Screen flash (level-up, etc.)
    screenFlash = {
        active = false,
        timer = 0,
        duration = 0.3,
        color = {1, 1, 1},
        alpha = 0,
    },

    -- Shield recharge flash effects
    shieldRechargeFlashes = {},
}

function VFXManager:init()
    self.shakeX = 0
    self.shakeY = 0
    self.shakeDuration = 0
    self.shakeIntensity = 0
    self.shakeTimer = 0
    self.hitFlashes = {}
    self.toolFlashes = {}
    self.deathEffects = {}
    self.floatingTexts = {}
    self.transition = {
        active = false,
        alpha = 0,
        speed = 0,
        phase = "none",
        onMidpoint = nil,
        onComplete = nil,
        midpointFired = false,
        fadeInSpeed = 0,
    }
    self.waveAnnouncement = {
        active = false,
        text = "",
        timer = 0,
        duration = Constants.VFX.WAVE_ANNOUNCEMENT_DURATION,
    }
    self.bossWarning = {
        active = false,
        timer = 0,
        duration = Constants.VFX.BOSS_WARNING_DURATION,
        flashTimer = 0,
        onComplete = nil,
    }
    self.destructionSequence = {
        active = false,
        timer = 0,
        phase = 0,
        x = 0,
        y = 0,
        rings = {},
        onComplete = nil,
    }
    self.defeatCelebration = {
        active = false,
        timer = 0,
        phase = 0,
        onComplete = nil,
    }
    self.screenFlash = {
        active = false, timer = 0, duration = 0.3,
        color = {1, 1, 1}, alpha = 0,
    }
    self.shieldRechargeFlashes = {}
end

function VFXManager:update(dt)
    self:updateShake(dt)
    self:updateHitFlashes(dt)
    self:updateToolFlashes(dt)
    self:updateDeathEffects(dt)
    self:updateFloatingTexts(dt)
    self:updateTransition(dt)
    self:updateWaveAnnouncement(dt)
    self:updateBossWarning(dt)
    self:updateDestructionSequence(dt)
    self:updateDefeatCelebration(dt)
    self:updateScreenFlash(dt)
    self:updateShieldRechargeFlashes(dt)
end

-- ============================================
-- Screen Shake
-- ============================================

function VFXManager:startShake(intensity, duration)
    -- Don't override a stronger shake
    if self.shakeTimer > 0 and self.shakeIntensity > intensity then
        return
    end
    self.shakeIntensity = intensity
    self.shakeDuration = duration
    self.shakeTimer = duration
end

function VFXManager:updateShake(dt)
    if self.shakeTimer > 0 then
        self.shakeTimer = self.shakeTimer - dt
        local progress = math.max(0, self.shakeTimer / self.shakeDuration)
        local intensity = self.shakeIntensity * progress
        self.shakeX = (math.random() * 2 - 1) * intensity
        self.shakeY = (math.random() * 2 - 1) * intensity
    else
        self.shakeX = 0
        self.shakeY = 0
    end
end

function VFXManager:getShakeOffset()
    return self.shakeX, self.shakeY
end

-- ============================================
-- Hit Flashes
-- ============================================

function VFXManager:addHitFlash(x, y, radius)
    table.insert(self.hitFlashes, {
        x = x,
        y = y,
        radius = radius or 8,
        timer = Constants.VFX.HIT_FLASH_DURATION,
        duration = Constants.VFX.HIT_FLASH_DURATION,
    })
end

function VFXManager:updateHitFlashes(dt)
    local i = 1
    while i <= #self.hitFlashes do
        local flash = self.hitFlashes[i]
        flash.timer = flash.timer - dt
        if flash.timer <= 0 then
            table.remove(self.hitFlashes, i)
        else
            i = i + 1
        end
    end
end

-- ============================================
-- Tool Fire Flashes
-- ============================================

function VFXManager:addToolFlash(x, y)
    table.insert(self.toolFlashes, {
        x = x, y = y,
        radius = 4, maxRadius = 12,
        timer = 0, duration = 0.15,
    })
end

function VFXManager:updateToolFlashes(dt)
    local i = 1
    while i <= #self.toolFlashes do
        local f = self.toolFlashes[i]
        f.timer = f.timer + dt
        if f.timer >= f.duration then
            table.remove(self.toolFlashes, i)
        else
            f.radius = 4 + (f.maxRadius - 4) * (f.timer / f.duration)
            i = i + 1
        end
    end
end

-- ============================================
-- Death Effects
-- ============================================

function VFXManager:addDeathEffect(x, y, radius)
    table.insert(self.deathEffects, {
        x = x,
        y = y,
        radius = 0,
        maxRadius = (radius or 8) + Constants.VFX.DEATH_EFFECT_MAX_RADIUS,
        timer = 0,
        duration = Constants.VFX.DEATH_EFFECT_DURATION,
    })
end

function VFXManager:updateDeathEffects(dt)
    local i = 1
    while i <= #self.deathEffects do
        local effect = self.deathEffects[i]
        effect.timer = effect.timer + dt
        if effect.timer >= effect.duration then
            table.remove(self.deathEffects, i)
        else
            local progress = effect.timer / effect.duration
            effect.radius = effect.maxRadius * progress
            i = i + 1
        end
    end
end

-- ============================================
-- Floating Text
-- ============================================

function VFXManager:addFloatingText(text, x, y, color)
    table.insert(self.floatingTexts, {
        text = text,
        x = x,
        y = y,
        startY = y,
        timer = 0,
        duration = Constants.VFX.FLOATING_TEXT_DURATION,
        color = color or {1, 1, 1},
        alpha = 1,
    })
end

function VFXManager:updateFloatingTexts(dt)
    local i = 1
    while i <= #self.floatingTexts do
        local ft = self.floatingTexts[i]
        ft.timer = ft.timer + dt
        if ft.timer >= ft.duration then
            table.remove(self.floatingTexts, i)
        else
            local progress = ft.timer / ft.duration
            ft.y = ft.startY - progress * Constants.VFX.FLOATING_TEXT_RISE
            ft.alpha = 1 - progress
            i = i + 1
        end
    end
end

-- ============================================
-- Screen Transition
-- ============================================

function VFXManager:startTransition(fadeOutDuration, onMidpoint, fadeInDuration, onComplete)
    fadeOutDuration = fadeOutDuration or Constants.VFX.TRANSITION_FADE_SPEED
    fadeInDuration = fadeInDuration or Constants.VFX.TRANSITION_FADE_SPEED

    self.transition = {
        active = true,
        alpha = 0,
        speed = 1 / fadeOutDuration,
        phase = "fade_out",
        onMidpoint = onMidpoint,
        onComplete = onComplete,
        midpointFired = false,
        fadeInSpeed = 1 / fadeInDuration,
    }
end

function VFXManager:updateTransition(dt)
    local t = self.transition
    if not t.active then return end

    if t.phase == "fade_out" then
        t.alpha = t.alpha + t.speed * dt
        if t.alpha >= 1 then
            t.alpha = 1
            -- Fire midpoint callback (scene change happens here)
            if not t.midpointFired and t.onMidpoint then
                t.midpointFired = true
                t.onMidpoint()
            end
            t.phase = "fade_in"
            t.speed = t.fadeInSpeed
        end
    elseif t.phase == "fade_in" then
        t.alpha = t.alpha - t.speed * dt
        if t.alpha <= 0 then
            t.alpha = 0
            t.active = false
            t.phase = "none"
            if t.onComplete then
                t.onComplete()
            end
        end
    end
end

function VFXManager:isTransitioning()
    return self.transition.active
end

-- ============================================
-- Wave Announcement
-- ============================================

function VFXManager:showWaveAnnouncement(waveNum)
    self.waveAnnouncement = {
        active = true,
        text = "WAVE " .. waveNum,
        timer = 0,
        duration = Constants.VFX.WAVE_ANNOUNCEMENT_DURATION,
    }
end

function VFXManager:updateWaveAnnouncement(dt)
    local wa = self.waveAnnouncement
    if not wa.active then return end

    wa.timer = wa.timer + dt
    if wa.timer >= wa.duration then
        wa.active = false
    end
end

-- ============================================
-- Boss Warning
-- ============================================

function VFXManager:showBossWarning(onComplete)
    self.bossWarning = {
        active = true,
        timer = 0,
        duration = Constants.VFX.BOSS_WARNING_DURATION,
        flashTimer = 0,
        onComplete = onComplete,
    }
end

function VFXManager:updateBossWarning(dt)
    local bw = self.bossWarning
    if not bw.active then return end

    bw.timer = bw.timer + dt
    bw.flashTimer = bw.flashTimer + dt

    if bw.timer >= bw.duration then
        bw.active = false
        if bw.onComplete then
            bw.onComplete()
        end
    end
end

-- ============================================
-- Station Destruction Sequence
-- ============================================

function VFXManager:startDestructionSequence(x, y, onComplete)
    self.destructionSequence = {
        active = true,
        timer = 0,
        phase = 0,
        x = x,
        y = y,
        rings = {},
        onComplete = onComplete,
    }

    -- Play destruction sound
    if AudioManager then
        AudioManager:playSFX("station_destroyed", 1.0)
    end
end

function VFXManager:updateDestructionSequence(dt)
    local ds = self.destructionSequence
    if not ds.active then return end

    ds.timer = ds.timer + dt

    -- Phase 0: White flash (0 - 0.2s)
    if ds.phase == 0 and ds.timer >= 0.2 then
        ds.phase = 1
        -- Spawn expanding rings
        for i = 1, 3 do
            table.insert(ds.rings, {
                radius = 0,
                maxRadius = 40 + i * 25,
                speed = 60 + i * 30,
            })
        end
    end

    -- Phase 1: Expanding rings (0.2 - 1.0s)
    if ds.phase == 1 then
        for _, ring in ipairs(ds.rings) do
            ring.radius = ring.radius + ring.speed * dt
        end

        if ds.timer >= 1.0 then
            ds.phase = 2
        end
    end

    -- Phase 2: Fade to black (1.0 - 1.5s)
    if ds.phase == 2 and ds.timer >= Constants.VFX.DESTRUCTION_DURATION then
        ds.active = false
        if ds.onComplete then
            ds.onComplete()
        end
    end
end

-- ============================================
-- Boss Defeat Celebration
-- ============================================

function VFXManager:startDefeatCelebration(onComplete)
    self.defeatCelebration = {
        active = true,
        timer = 0,
        phase = 0,
        onComplete = onComplete,
    }
end

function VFXManager:updateDefeatCelebration(dt)
    local dc = self.defeatCelebration
    if not dc.active then return end

    dc.timer = dc.timer + dt

    -- Phase 0: Freeze + flash (0 - 0.5s)
    if dc.phase == 0 and dc.timer >= 0.5 then
        dc.phase = 1
    end

    -- Phase 1: Flash fades (0.5 - 0.8s)
    if dc.phase == 1 and dc.timer >= Constants.VFX.CELEBRATION_DURATION then
        dc.active = false
        if dc.onComplete then
            dc.onComplete()
        end
    end
end

-- ============================================
-- Screen Flash
-- ============================================

function VFXManager:addScreenFlash(color, duration)
    self.screenFlash = {
        active = true,
        timer = 0,
        duration = duration or 0.3,
        color = color or {1, 1, 1},
        alpha = 0.4,
    }
end

function VFXManager:updateScreenFlash(dt)
    local sf = self.screenFlash
    if not sf.active then return end
    sf.timer = sf.timer + dt
    if sf.timer >= sf.duration then
        sf.active = false
        sf.alpha = 0
    else
        sf.alpha = 0.4 * (1 - sf.timer / sf.duration)
    end
end

-- ============================================
-- Shield Recharge Flash
-- ============================================

function VFXManager:addShieldRechargeFlash(x, y)
    table.insert(self.shieldRechargeFlashes, {
        x = x, y = y,
        radius = 10, maxRadius = 30,
        timer = 0, duration = 0.35,
    })
end

function VFXManager:updateShieldRechargeFlashes(dt)
    local i = 1
    while i <= #self.shieldRechargeFlashes do
        local f = self.shieldRechargeFlashes[i]
        f.timer = f.timer + dt
        if f.timer >= f.duration then
            table.remove(self.shieldRechargeFlashes, i)
        else
            f.radius = f.maxRadius * (f.timer / f.duration)
            i = i + 1
        end
    end
end

-- ============================================
-- Sequence Active Check
-- ============================================

function VFXManager:isSequenceActive()
    return self.destructionSequence.active or self.defeatCelebration.active or self.bossWarning.active
end

-- ============================================
-- Drawing - World Space (affected by shake)
-- ============================================

function VFXManager:drawWorld()
    -- Tool fire flashes (expanding ring)
    for _, f in ipairs(self.toolFlashes) do
        local alpha = 1 - (f.timer / f.duration)
        love.graphics.setColor(1, 1, 1, alpha * 0.5)
        love.graphics.circle("line", f.x, f.y, f.radius)
    end

    -- Hit flashes
    for _, flash in ipairs(self.hitFlashes) do
        local alpha = flash.timer / flash.duration
        love.graphics.setColor(1, 1, 1, alpha * 0.8)
        love.graphics.circle("fill", flash.x, flash.y, flash.radius)
    end

    -- Death effects
    for _, effect in ipairs(self.deathEffects) do
        local progress = effect.timer / effect.duration
        local alpha = 1 - progress
        love.graphics.setColor(1, 1, 1, alpha * 0.7)
        love.graphics.circle("line", effect.x, effect.y, effect.radius)
        love.graphics.setColor(1, 1, 1, alpha * 0.2)
        love.graphics.circle("fill", effect.x, effect.y, effect.radius)
    end

    -- Shield recharge flashes
    for _, f in ipairs(self.shieldRechargeFlashes) do
        local progress = f.timer / f.duration
        local alpha = 0.7 * (1 - progress)
        love.graphics.setColor(0, 0.8, 1.0, alpha)
        love.graphics.circle("line", f.x, f.y, f.radius)
    end

    -- Floating text
    local font = love.graphics.getFont()
    for _, ft in ipairs(self.floatingTexts) do
        love.graphics.setColor(ft.color[1], ft.color[2], ft.color[3], ft.alpha)
        local textW = font:getWidth(ft.text)
        love.graphics.print(ft.text, ft.x - textW / 2, ft.y)
    end

    -- Destruction sequence rings
    local ds = self.destructionSequence
    if ds.active and ds.phase >= 1 then
        for _, ring in ipairs(ds.rings) do
            local alpha = math.max(0, 1 - ring.radius / ring.maxRadius)
            love.graphics.setColor(1, 0.8, 0.3, alpha * 0.8)
            love.graphics.circle("line", ds.x, ds.y, ring.radius)
        end
    end

    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

-- ============================================
-- Drawing - Overlay (not affected by shake)
-- ============================================

function VFXManager:drawOverlay()
    local font = love.graphics.getFont()
    local centerX = Constants.SCREEN_WIDTH / 2
    local centerY = Constants.SCREEN_HEIGHT / 2

    -- Destruction sequence flash
    local ds = self.destructionSequence
    if ds.active then
        if ds.phase == 0 then
            -- White flash
            local alpha = 1 - (ds.timer / 0.2)
            love.graphics.setColor(1, 1, 1, math.max(0, alpha))
            love.graphics.rectangle("fill", 0, 0, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT)
        elseif ds.phase == 2 then
            -- Fade to black
            local fadeProgress = (ds.timer - 1.0) / (Constants.VFX.DESTRUCTION_DURATION - 1.0)
            love.graphics.setColor(0, 0, 0, Utils.clamp(fadeProgress, 0, 1))
            love.graphics.rectangle("fill", 0, 0, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT)
        end
    end

    -- Defeat celebration flash
    local dc = self.defeatCelebration
    if dc.active then
        if dc.phase == 0 then
            -- White flash builds
            local alpha = math.min(1, dc.timer / 0.15)
            love.graphics.setColor(1, 1, 1, alpha * 0.6)
            love.graphics.rectangle("fill", 0, 0, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT)
        elseif dc.phase == 1 then
            -- Flash fades out
            local fadeProgress = (dc.timer - 0.5) / 0.3
            local alpha = math.max(0, 0.6 * (1 - fadeProgress))
            love.graphics.setColor(1, 1, 1, alpha)
            love.graphics.rectangle("fill", 0, 0, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT)
        end
    end

    -- Boss warning
    local bw = self.bossWarning
    if bw.active then
        -- Red flash overlay (pulsing)
        local flashAlpha = math.abs(math.sin(bw.flashTimer * 6)) * 0.2
        love.graphics.setColor(1, 0, 0, flashAlpha)
        love.graphics.rectangle("fill", 0, 0, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT)

        -- "WARNING" text
        local warningAlpha = math.min(1, bw.timer / 0.3)
        love.graphics.setColor(1, 0.2, 0.2, warningAlpha)
        local warningText = "WARNING"
        local warningW = font:getWidth(warningText)
        love.graphics.print(warningText, centerX - warningW / 2, centerY - 20)

        -- Subtitle
        love.graphics.setColor(1, 0.5, 0.3, warningAlpha * 0.8)
        local subText = "Boss Approaching"
        local subW = font:getWidth(subText)
        love.graphics.print(subText, centerX - subW / 2, centerY)
    end

    -- Wave announcement
    local wa = self.waveAnnouncement
    if wa.active then
        local progress = wa.timer / wa.duration
        local alpha
        if progress < 0.2 then
            -- Fade in
            alpha = progress / 0.2
        elseif progress < 0.7 then
            -- Hold
            alpha = 1
        else
            -- Fade out
            alpha = 1 - (progress - 0.7) / 0.3
        end

        love.graphics.setColor(1, 1, 1, alpha)
        local textW = font:getWidth(wa.text)
        love.graphics.print(wa.text, centerX - textW / 2, centerY - 30)
    end

    -- Screen flash (level-up, etc.)
    local sf = self.screenFlash
    if sf.active then
        love.graphics.setColor(sf.color[1], sf.color[2], sf.color[3], sf.alpha)
        love.graphics.rectangle("fill", 0, 0, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT)
    end

    -- Screen transition (drawn last, on top of everything)
    if self.transition.active then
        love.graphics.setColor(0, 0, 0, self.transition.alpha)
        love.graphics.rectangle("fill", 0, 0, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT)
    end

    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

return VFXManager
