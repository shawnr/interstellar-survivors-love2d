-- Gameplay Scene
-- Main game loop where combat happens

-- Class registries for data-driven spawning
local MOB_CLASSES = {
    Asteroid = function() return Asteroid end,
    GreetingDrone = function() return GreetingDrone end,
    SilkWeaver = function() return SilkWeaver end,
    SurveyDrone = function() return SurveyDrone end,
    EfficiencyMonitor = function() return EfficiencyMonitor end,
    ProbabilityFluctuation = function() return ProbabilityFluctuation end,
    ParadoxNode = function() return ParadoxNode end,
    DebrisChunk = function() return DebrisChunk end,
    DefenseTurret = function() return DefenseTurret end,
    DebateDrone = function() return DebateDrone end,
    CitationPlatform = function() return CitationPlatform end,
}

local BOSS_CLASSES = {
    CulturalAttache = function() return CulturalAttache end,
    ProductivityLiaison = function() return ProductivityLiaison end,
    ImprobabilityEngine = function() return ImprobabilityEngine end,
    Chomper = function() return Chomper end,
    DistinguishedProfessor = function() return DistinguishedProfessor end,
}

GameplayScene = {
    -- Game state
    isPaused = false,
    isLevelingUp = false,
    isPlacingTool = false,
    pendingToolOption = nil,
    elapsedTime = 0,

    -- Entity references
    station = nil,
    mobs = {},
    boss = nil,
    bossSpawned = false,

    -- Object pools
    projectilePool = nil,
    collectiblePool = nil,
    enemyProjectilePool = nil,

    -- Visual effects
    pulseEffects = {},

    -- Wave management
    currentWave = 1,
    spawnTimer = 0,
    spawnInterval = 1.5,
    waveStartTimes = { 0, 20, 40, 60, 80, 100, 120 },
    bossWave = 7,  -- Boss spawns at wave 7

    -- Background
    backgroundImage = nil,
    starfield = {},

    -- Slow effect (from Silk Weaver projectiles)
    slowEffect = false,
    slowTimer = 0,
    slowDuration = 2.0,
    slowMultiplier = 0.5,

    -- Fire rate debuff (from Productivity Liaison boss) — affects half the tools
    fireRateDebuff = false,
    fireRateDebuffTimer = 0,
    fireRateDebuffDuration = 2.0,
    fireRateDebuffMultiplier = 0.5,
    jammedTools = {},  -- Track which tools are jammed

    -- Control inversion debuff (from ImprobabilityEngine boss)
    controlInversion = false,
    controlInversionTimer = 0,
    controlInversionDuration = 3.0,

    -- Auto level-up choice (set when player picks "Always RP" or "Always Health")
    autoLevelChoice = nil,  -- nil, "rp", or "health"

    -- Run stats (for results screen)
    stats = nil,
}

function GameplayScene:init()
    self.isPaused = false
    self.isLevelingUp = false
    self.isPlacingTool = false
    self.pendingToolOption = nil
    self.elapsedTime = 0
    self.mobs = {}
    self.boss = nil
    self.bossSpawned = false
    self.currentWave = 1
    self.spawnTimer = 0
    self.spawnInterval = 1.5
    self.pulseEffects = {}
    self.slowEffect = false
    self.slowTimer = 0
    self.fireRateDebuff = false
    self.fireRateDebuffTimer = 0
    self.jammedTools = {}
    self.controlInversion = false
    self.controlInversionTimer = 0
    self.autoLevelChoice = nil
    self.stats = { mobKills = 0 }

    -- On-kill effects tracking
    self.killCounter = 0

    -- Health regeneration timer
    self.regenTimer = 0
end

function GameplayScene:enter(params)
    print("Entering gameplay scene")

    params = params or {}

    -- Reset state
    self.isPaused = false
    self.isLevelingUp = false
    self.isPlacingTool = false
    self.pendingToolOption = nil
    self.elapsedTime = 0
    self.currentWave = 1
    self.spawnTimer = 0
    self.mobs = {}
    self.boss = nil
    self.bossSpawned = false
    self.pulseEffects = {}
    self.slowEffect = false
    self.slowTimer = 0
    self.fireRateDebuff = false
    self.fireRateDebuffTimer = 0
    self.jammedTools = {}
    self.controlInversion = false
    self.controlInversionTimer = 0
    self.autoLevelChoice = nil
    self.stats = { mobKills = 0 }

    -- On-kill effects tracking
    self.killCounter = 0

    -- Health regeneration timer
    self.regenTimer = 0

    -- Reset VFX
    VFXManager:init()

    -- Reset upgrade system
    if UpgradeSystem then
        UpgradeSystem:reset()
        UpgradeSystem:setEpisode(GameManager.currentEpisodeId or 1)
    end

    -- Create object pools
    self.projectilePool = ProjectilePool(50)
    self.collectiblePool = CollectiblePool(100)
    self.enemyProjectilePool = EnemyProjectilePool(30)

    -- Create station
    self.station = Station()

    -- Give station starting tool (Rail Driver only)
    local railDriver = RailDriver()
    self.station:attachTool(railDriver)

    -- Apply meta-progression bonuses
    if GrantsSystem then
        GrantsSystem:applyToGameplay(self.station)
    end
    if SpecsSystem then
        SpecsSystem:applyToGameplay(self.station)
    end

    -- Reset bonus items for this run
    if BonusItemsSystem then
        BonusItemsSystem:reset()
    end

    -- Load background from episode data
    local bgPath = "assets/images/episodes/ep1/bg_ep1.png"
    if params.episodeData and params.episodeData.backgroundPath then
        bgPath = params.episodeData.backgroundPath
    end
    self.backgroundImage = Utils.getCachedImage(bgPath)

    -- Generate starfield
    self.starfield = {}
    for i = 1, 40 do
        table.insert(self.starfield, {
            x = math.random(0, Constants.SCREEN_WIDTH),
            y = math.random(0, Constants.SCREEN_HEIGHT),
            brightness = 0.15 + math.random() * 0.25,
            speed = 0.3 + math.random() * 0.5,
        })
    end

    -- Discover episode in codex
    if SaveManager then
        SaveManager:discoverEntry("ep_" .. (GameManager.currentEpisodeId or 1))
        SaveManager:discoverEntry("tool_rail_driver")
    end

    if AudioManager then
        AudioManager:playMusic("music_gameplay")
    end
    print("Gameplay scene entered with 1 starting tool")
end

function GameplayScene:pause()
    self.isPaused = true
    PauseMenu:show()
end

function GameplayScene:unpause()
    self.isPaused = false
    PauseMenu:hide()
end

function GameplayScene:update(dt)
    -- Handle pause toggle (before any other updates)
    if not self.isLevelingUp and not VFXManager:isSequenceActive() then
        if InputManager:justPressed("escape") then
            if self.isPaused then
                self:unpause()
            else
                self:pause()
            end
        end
    end

    -- Handle slot picker UI
    if self.isPlacingTool then
        if SlotPicker then
            SlotPicker:update(dt)
        end
        return
    end

    -- Handle upgrade selection UI
    if self.isLevelingUp then
        if UpgradeSelection then
            UpgradeSelection:update(dt)
        end
        return
    end

    -- Handle pause menu
    if self.isPaused then
        PauseMenu:update(dt)
        return
    end

    -- Block gameplay during cinematic sequences
    if VFXManager:isSequenceActive() then
        return
    end

    -- Update elapsed time
    self.elapsedTime = self.elapsedTime + dt

    -- Health regeneration (Backup Generator bonus item)
    if BonusItemsSystem then
        self.regenTimer = self.regenTimer + dt
        if self.regenTimer >= 5.0 then
            self.regenTimer = 0
            local regen = BonusItemsSystem:getHealthRegen()
            if regen > 0 and self.station then
                self.station:heal(regen)
            end
        end
    end

    -- Update starfield drift
    for _, star in ipairs(self.starfield) do
        star.y = star.y + star.speed * dt * 8
        if star.y > Constants.SCREEN_HEIGHT then
            star.y = star.y - Constants.SCREEN_HEIGHT
            star.x = math.random(0, Constants.SCREEN_WIDTH)
        end
    end

    -- Update slow effect
    if self.slowEffect then
        self.slowTimer = self.slowTimer - dt
        if self.slowTimer <= 0 then
            self.slowEffect = false
            InputManager:setRotationSpeedMultiplier(1.0)
        end
    end

    -- Update fire rate debuff
    if self.fireRateDebuff then
        self.fireRateDebuffTimer = self.fireRateDebuffTimer - dt
        if self.fireRateDebuffTimer <= 0 then
            self.fireRateDebuff = false
            -- Restore normal fire intervals on jammed tools
            for _, tool in ipairs(self.station.tools) do
                if self.jammedTools[tool] then
                    tool:recalculateStats()
                end
            end
            self.jammedTools = {}
        end
    end

    -- Update control inversion debuff
    if self.controlInversion then
        self.controlInversionTimer = self.controlInversionTimer - dt
        if self.controlInversionTimer <= 0 then
            self.controlInversion = false
            InputManager:setControlInversion(false)
        end
    end

    -- Update station
    self.station:update(dt)

    -- Update tools
    for _, tool in ipairs(self.station.tools) do
        tool:update(dt)
    end

    -- Update projectiles
    self.projectilePool:update(dt)
    self.enemyProjectilePool:update(dt)

    -- Update MOBs
    self:updateMOBs(dt)

    -- Update boss
    if self.boss and self.boss.active then
        self.boss:update(dt)
    end

    -- Update collectibles
    self.collectiblePool:update(dt)

    -- Update pulse effects
    self:updatePulseEffects(dt)

    -- Spawn new MOBs
    self:updateSpawning(dt)

    -- Check collisions
    self:checkCollisions()

    -- Update wave
    self:updateWave()
end

function GameplayScene:updateMOBs(dt)
    -- Update and remove dead mobs
    local n = #self.mobs
    local i = 1
    while i <= n do
        local mob = self.mobs[i]
        if mob.active then
            mob:update(dt)
            i = i + 1
        else
            -- Track kill
            if self.stats then
                self.stats.mobKills = (self.stats.mobKills or 0) + 1
            end
            -- Swap-and-pop removal
            self.mobs[i] = self.mobs[n]
            self.mobs[n] = nil
            n = n - 1
        end
    end
end

function GameplayScene:updateSpawning(dt)
    self.spawnTimer = self.spawnTimer - dt

    if self.spawnTimer <= 0 then
        self:spawnMOB()
        self.spawnTimer = self.spawnInterval
    end
end

function GameplayScene:updateWave()
    -- Check if we should advance to next wave
    for i = #self.waveStartTimes, 1, -1 do
        if self.elapsedTime >= self.waveStartTimes[i] and self.currentWave < i then
            self.currentWave = i
            self:onWaveStart(i)
            break
        end
    end
end

function GameplayScene:onWaveStart(waveNum)
    print("Wave " .. waveNum .. " started!")

    -- Show wave announcement
    VFXManager:showWaveAnnouncement(waveNum)

    -- Play wave start sound
    if AudioManager then
        AudioManager:playSFX("wave_start", 0.5)
    end

    -- Adjust spawn interval per wave
    local spawnRates = { 1.5, 1.2, 1.0, 0.8, 0.7, 0.6, 0.5 }
    self.spawnInterval = spawnRates[waveNum] or 0.5

    -- Spawn boss at wave 7
    if waveNum >= self.bossWave and not self.bossSpawned then
        self:spawnBoss()
    end
end

function GameplayScene:spawnBoss()
    if self.bossSpawned then return end
    self.bossSpawned = true  -- Prevent re-entry

    -- Look up boss class from episode data
    local episodeId = GameManager.currentEpisodeId or 1
    local bossClassName = EpisodesData.getBossClass(episodeId)
    local bossClassFn = BOSS_CLASSES[bossClassName]

    if not bossClassFn then
        print("WARNING: Unknown boss class: " .. tostring(bossClassName))
        return
    end

    -- Show boss warning, then spawn after warning completes
    VFXManager:showBossWarning(function()
        local x, y = Utils.randomEdgePoint(60)
        local BossClass = bossClassFn()
        self.boss = BossClass(x, y)

        if AudioManager then
            AudioManager:playSFX("wave_start", 1.0)
            -- Switch to boss music
            AudioManager:playMusic("music_boss")
        end

        -- Discover boss in codex
        if SaveManager and self.boss and self.boss.data and self.boss.data.id then
            SaveManager:discoverEntry("boss_" .. self.boss.data.id)
        end

        print("BOSS SPAWNED: " .. bossClassName)
    end)
end

function GameplayScene:spawnMOB()
    -- Limit active MOBs
    if #self.mobs >= Constants.MAX_ACTIVE_MOBS then
        return
    end

    -- Random spawn position on screen edge
    local x, y = Utils.randomEdgePoint(30)

    -- Wave multipliers
    local multipliers = {
        health = 1.0 + (self.currentWave - 1) * 0.15,
        damage = 1.0 + (self.currentWave - 1) * 0.1,
        speed = 1.0 + (self.currentWave - 1) * 0.05
    }

    -- Get spawn config for current episode
    local episodeId = GameManager.currentEpisodeId or 1
    local spawnConfig = EpisodesData.getSpawnConfig(episodeId)

    -- Find the weight table for the current wave
    local weights = nil
    for _, entry in ipairs(spawnConfig) do
        local minWave, maxWave = entry.waveRange[1], entry.waveRange[2]
        if self.currentWave >= minWave and self.currentWave <= maxWave then
            weights = entry.weights
            break
        end
    end

    -- Fallback to last entry if wave exceeds all ranges
    if not weights and #spawnConfig > 0 then
        weights = spawnConfig[#spawnConfig].weights
    end

    if not weights then return end

    -- Weighted random selection
    local totalWeight = 0
    for _, w in ipairs(weights) do
        totalWeight = totalWeight + w.weight
    end

    local roll = math.random() * totalWeight
    local cumulative = 0
    local chosen = nil

    for _, w in ipairs(weights) do
        cumulative = cumulative + w.weight
        if roll <= cumulative then
            chosen = w
            break
        end
    end

    if not chosen then return end

    -- Instantiate the chosen mob
    local classFn = MOB_CLASSES[chosen.class]
    if not classFn then
        print("WARNING: Unknown mob class: " .. tostring(chosen.class))
        return
    end

    local MobClass = classFn()
    local mob

    -- Special case: Asteroid takes a level argument
    if chosen.class == "Asteroid" and chosen.args and chosen.args.level then
        local level = chosen.args.level
        if type(level) == "table" then
            level = math.random(level[1], level[2])
        end
        mob = MobClass(x, y, multipliers, level)
    else
        mob = MobClass(x, y, multipliers)
    end

    if mob then
        table.insert(self.mobs, mob)

        -- Discover mob in codex
        if SaveManager and mob.data and mob.data.id then
            SaveManager:discoverEntry("mob_" .. mob.data.id)
        end
    end
end

function GameplayScene:checkCollisions()
    -- Player Projectiles vs MOBs
    local projectiles = self.projectilePool:getActive()
    local minTravelDistSq = 8 * 8  -- Min travel before collision enabled

    for _, proj in ipairs(projectiles) do
        if proj.active then
            -- Orbital projectiles skip travel distance check (they stay near center)
            local canCollide = proj.orbital
            if not canCollide then
                local travelDistSq = Utils.distanceSquared(proj.x, proj.y, proj.spawnX, proj.spawnY)
                canCollide = travelDistSq >= minTravelDistSq
            end

            if canCollide then
                for _, mob in ipairs(self.mobs) do
                    if mob.active and not mob.isDying then
                        -- Skip if this target was already hit this tick (for orbital/piercing)
                        if proj.hitTargets and proj.hitTargets[mob] then
                            -- Already hit this target in current tick
                        else
                            local mobRadius = mob:getRadius()
                            local collisionDist = mobRadius + 6
                            local collisionDistSq = collisionDist * collisionDist

                            local distSq = Utils.distanceSquared(proj.x, proj.y, mob.x, mob.y)

                            if distSq < collisionDistSq then
                                mob:takeDamage(proj:getDamage())

                                -- Show crit VFX if this was a critical hit
                                if proj.wasCrit and VFXManager then
                                    VFXManager:addFloatingText("CRIT!", mob.x, mob.y - 15, {1, 1, 0})
                                end

                                -- Track hit target for tick-based projectiles
                                if proj.hitTargets then
                                    proj.hitTargets[mob] = true
                                end

                                -- Call onHitCallback if set (chain lightning, etc.)
                                if proj.onHitCallback then
                                    proj.onHitCallback(proj, mob)
                                end

                                proj:onHit(mob)

                                if not proj.active then
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Player Projectiles vs Boss
    if self.boss and self.boss.active then
        for _, proj in ipairs(projectiles) do
            if proj.active then
                local canCollide = proj.orbital
                if not canCollide then
                    local travelDistSq = Utils.distanceSquared(proj.x, proj.y, proj.spawnX, proj.spawnY)
                    canCollide = travelDistSq >= minTravelDistSq
                end

                if canCollide then
                    -- Skip if already hit boss this tick
                    if not (proj.hitTargets and proj.hitTargets[self.boss]) then
                        local bossRadius = self.boss:getRadius()
                        local collisionDist = bossRadius + 6
                        local collisionDistSq = collisionDist * collisionDist
                        local distSq = Utils.distanceSquared(proj.x, proj.y, self.boss.x, self.boss.y)

                        if distSq < collisionDistSq then
                            self.boss:takeDamage(proj:getDamage())

                            -- Crit VFX for boss hits
                            if proj.wasCrit and VFXManager then
                                VFXManager:addFloatingText("CRIT!", self.boss.x, self.boss.y - 15, {1, 1, 0})
                            end

                            if proj.hitTargets then
                                proj.hitTargets[self.boss] = true
                            end

                            if proj.onHitCallback then
                                proj.onHitCallback(proj, self.boss)
                            end

                            proj:onHit(self.boss)
                        end
                    end
                end
            end
        end
    end

    -- Melee MOBs vs Station (ramming enemies only)
    for _, mob in ipairs(self.mobs) do
        if mob.active and not mob.emits and not mob.isDying then
            local distSq = Utils.distanceSquared(mob.x, mob.y, self.station.x, self.station.y)
            local mobRadius = mob:getRadius()
            local collisionDist = Constants.STATION_RADIUS + mobRadius
            local collisionDistSq = collisionDist * collisionDist

            if distSq < collisionDistSq then
                -- MOB hit station
                local attackAngle = Utils.vectorToAngle(mob.x - self.station.x, mob.y - self.station.y)
                self.station:takeDamage(mob.damage, attackAngle)
                mob:onDestroyed()
            end
        end
    end

    -- Enemy Projectiles vs Station
    local enemyProjectiles = self.enemyProjectilePool:getActive()
    for _, proj in ipairs(enemyProjectiles) do
        if proj.active then
            local distSq = Utils.distanceSquared(proj.x, proj.y, self.station.x, self.station.y)
            local collisionDist = Constants.STATION_RADIUS + proj.radius
            local collisionDistSq = collisionDist * collisionDist

            if distSq < collisionDistSq then
                -- Enemy projectile hit station
                local attackAngle = Utils.vectorToAngle(proj.x - self.station.x, proj.y - self.station.y)
                self.station:takeDamage(proj:getDamage(), attackAngle, "projectile")

                -- Apply special effect
                local effect = proj:getEffect()
                if effect == "slow" then
                    self:applySlowEffect()
                end

                proj:deactivate()
            end
        end
    end
end

function GameplayScene:applySlowEffect()
    self.slowEffect = true
    self.slowTimer = self.slowDuration
    InputManager:setRotationSpeedMultiplier(self.slowMultiplier)

    -- Play slow effect sound
    if AudioManager then
        AudioManager:playSFX("station_hit", 0.4)
    end

    print("Station slowed by web!")
end

function GameplayScene:applyFireRateDebuff()
    self.fireRateDebuff = true
    self.fireRateDebuffTimer = self.fireRateDebuffDuration

    -- Select half the tools randomly to jam
    self.jammedTools = {}
    local toolCount = #self.station.tools
    local jamCount = math.ceil(toolCount / 2)

    -- Build shuffled index list
    local indices = {}
    for i = 1, toolCount do
        table.insert(indices, i)
    end
    for i = #indices, 2, -1 do
        local j = math.random(i)
        indices[i], indices[j] = indices[j], indices[i]
    end

    -- Jam the first jamCount tools from shuffled list
    for i = 1, jamCount do
        local tool = self.station.tools[indices[i]]
        if tool then
            self.jammedTools[tool] = true
            tool.fireInterval = tool.fireInterval / self.fireRateDebuffMultiplier
        end
    end

    if AudioManager then
        AudioManager:playSFX("station_hit", 0.4)
    end

    print("Station fire rate jammed! (" .. jamCount .. "/" .. toolCount .. " tools)")
end

-- Re-apply fire rate debuff after stat recalculation (only to jammed tools)
function GameplayScene:reapplyFireRateDebuffIfActive()
    if self.fireRateDebuff then
        for _, tool in ipairs(self.station.tools) do
            if self.jammedTools[tool] then
                tool.fireInterval = tool.fireInterval / self.fireRateDebuffMultiplier
            end
        end
    end
end

function GameplayScene:applyControlInversion()
    self.controlInversion = true
    self.controlInversionTimer = self.controlInversionDuration
    InputManager:setControlInversion(true)

    if AudioManager then
        AudioManager:playSFX("station_hit", 0.4)
    end

    print("Controls scrambled!")
end

function GameplayScene:onLevelUp()
    print("Level up callback in gameplay scene - Level " .. GameManager.playerLevel)

    -- Play level up sound and flash always
    if AudioManager then
        AudioManager:playSFX("level_up", 0.7)
    end
    if VFXManager then
        VFXManager:addScreenFlash({1, 0.9, 0.5}, 0.3)
    end

    -- Auto-level: if player previously chose "Always RP" or "Always Health", apply directly
    if self.autoLevelChoice then
        self:applyFallbackBonus(self.autoLevelChoice)
        return
    end

    -- Get upgrade options from UpgradeSystem
    if UpgradeSystem and UpgradeSelection then
        local options = UpgradeSystem:getUpgradeOptions(self.station)

        if #options > 0 then
            -- Normal upgrade selection (up to 2 tools + up to 2 bonus items)
            self.isLevelingUp = true
            UpgradeSelection:show(options, function(selected)
                self:onUpgradeSelected(selected)
            end)
        else
            -- All equipment maxed — show fallback options
            local fallbackOptions = {
                { type = "fallback", action = "rp", name = "RP Bonus", description = "Gain 25 Research Points" },
                { type = "fallback", action = "health", name = "Health Bonus", description = "Restore 10% HP" },
                { type = "fallback", action = "always_rp", name = "Always RP", description = "Auto-select RP each level" },
                { type = "fallback", action = "always_health", name = "Always Health", description = "Auto-select HP each level" },
            }
            self.isLevelingUp = true
            UpgradeSelection:show(fallbackOptions, function(selected)
                self:onUpgradeSelected(selected)
            end)
        end
    end
end

function GameplayScene:applyFallbackBonus(bonusType)
    if bonusType == "rp" then
        if GameManager then
            GameManager:awardRP(25)
        end
        if VFXManager then
            VFXManager:addFloatingText("+25 RP", self.station.x, self.station.y - 30, {1, 0.9, 0.2})
        end
    elseif bonusType == "health" then
        if self.station then
            local hpBonus = math.floor(self.station.maxHealth * 0.10)
            self.station:heal(hpBonus)
        end
        if VFXManager then
            VFXManager:addFloatingText("+HP", self.station.x, self.station.y - 30, {0.2, 1, 0.2})
        end
    end
end

function GameplayScene:onUpgradeSelected(option)
    print("Upgrade selected: " .. (option.name or "unknown"))

    if option.type == "fallback" then
        if option.action == "rp" then
            self:applyFallbackBonus("rp")
        elseif option.action == "health" then
            self:applyFallbackBonus("health")
        elseif option.action == "always_rp" then
            self.autoLevelChoice = "rp"
            self:applyFallbackBonus("rp")
        elseif option.action == "always_health" then
            self.autoLevelChoice = "health"
            self:applyFallbackBonus("health")
        end
        self.isLevelingUp = false
        return
    end

    if option.type == "bonus_item" then
        -- Bonus item: apply immediately, no slot picker
        if BonusItemsSystem and option.bonusItemData then
            BonusItemsSystem:applyItem(option.bonusItemData, self.station)
            if VFXManager then
                VFXManager:addFloatingText(option.name, self.station.x, self.station.y - 30, {0.2, 1, 0.5})
            end

            -- Check for auto-evolution triggered by this bonus item reaching max level
            if UpgradeSystem then
                local evoInfo = UpgradeSystem:checkBonusEvolution(option.bonusItemData, self.station)
                if evoInfo then
                    self:showEvolutionEffect(evoInfo)
                end
            end
        end

        -- Small heal bonus on level up
        if self.station then
            local hpBonus = math.floor(self.station.maxHealth * 0.05)
            self.station:heal(hpBonus)
        end

        -- Resume gameplay
        self.isLevelingUp = false
    elseif option.isNew then
        -- New tool: show slot picker for placement
        self.pendingToolOption = option
        self.isLevelingUp = false
        self.isPlacingTool = true
        SlotPicker:show(self.station, option, function(slotIndex)
            self:onSlotSelected(slotIndex)
        end)
    else
        -- Upgrade existing tool: apply immediately (slot already known)
        local evolutionInfo = nil
        if UpgradeSystem then
            local success
            success, evolutionInfo = UpgradeSystem:applyToolSelection(option, self.station)
        end

        -- Re-apply fire rate debuff if active (recalculateStats resets fireInterval)
        self:reapplyFireRateDebuffIfActive()

        -- Show evolution effect if auto-evolved
        if evolutionInfo then
            self:showEvolutionEffect(evolutionInfo)
        end

        -- Discover tool in codex
        if SaveManager and option.id then
            SaveManager:discoverEntry("tool_" .. option.id)
        end

        -- Small heal bonus on level up
        if self.station then
            local hpBonus = math.floor(self.station.maxHealth * 0.05)
            self.station:heal(hpBonus)
        end

        -- Resume gameplay
        self.isLevelingUp = false
    end
end

function GameplayScene:onSlotSelected(slotIndex)
    local option = self.pendingToolOption
    if not option then return end

    print("Placing tool in slot " .. slotIndex)

    -- Apply the upgrade with specific slot
    if UpgradeSystem then
        UpgradeSystem:applyToolSelection(option, self.station, slotIndex)
    end

    -- Re-apply fire rate debuff if active
    self:reapplyFireRateDebuffIfActive()

    -- Discover tool in codex
    if SaveManager and option.id then
        SaveManager:discoverEntry("tool_" .. option.id)
    end

    -- Small heal bonus on level up
    if self.station then
        local hpBonus = math.floor(self.station.maxHealth * 0.05)
        self.station:heal(hpBonus)
    end

    -- Resume gameplay
    self.isPlacingTool = false
    self.pendingToolOption = nil
end

-- Show evolution VFX when a tool auto-evolves
function GameplayScene:showEvolutionEffect(evolutionInfo)
    if not evolutionInfo or not evolutionInfo.evolved then return end

    local name = evolutionInfo.evolvedName or "EVOLVED"
    if VFXManager then
        VFXManager:addFloatingText(
            name .. "!",
            self.station.x, self.station.y - 30,
            {1, 0.8, 0}
        )
        VFXManager:addScreenFlash({1, 1, 1}, 0.3)
    end
    if AudioManager then
        AudioManager:playSFX("tool_upgrade", 0.8)
    end
end

-- Called when a MOB is destroyed (for on-kill bonus effects)
function GameplayScene:onMobKilled(mob)
    if not BonusItemsSystem then return end

    -- HP on Kill (Kinetic Absorber): heal 1 HP every N kills
    local hpThreshold = BonusItemsSystem:getHPOnKillThreshold()
    if hpThreshold > 0 then
        self.killCounter = (self.killCounter or 0) + 1
        if self.killCounter >= hpThreshold then
            self.killCounter = 0
            if self.station then
                self.station:heal(1)
                if VFXManager then
                    VFXManager:addFloatingText("+1", self.station.x, self.station.y - 20, {0.3, 1, 0.3})
                end
            end
        end
    end

    -- Cooldown on Kill (Rapid Loader): reduce all tool cooldowns by percentage
    local cooldownReduction = BonusItemsSystem:getCooldownOnKill()
    if cooldownReduction > 0 and self.station then
        for _, tool in ipairs(self.station.tools) do
            tool.fireCooldown = tool.fireCooldown * (1 - cooldownReduction)
        end
    end
end

-- Create a pulse effect (called by TractorPulse tool)
function GameplayScene:createPulseEffect(x, y, radius, duration)
    local pulse = {
        x = x,
        y = y,
        radius = radius,
        maxRadius = radius,
        duration = duration,
        elapsed = 0,
        alpha = 0.6
    }
    table.insert(self.pulseEffects, pulse)
end

function GameplayScene:updatePulseEffects(dt)
    local n = #self.pulseEffects
    local i = 1
    while i <= n do
        local pulse = self.pulseEffects[i]
        pulse.elapsed = pulse.elapsed + dt

        if pulse.elapsed >= pulse.duration then
            -- Remove pulse
            self.pulseEffects[i] = self.pulseEffects[n]
            self.pulseEffects[n] = nil
            n = n - 1
        else
            -- Update alpha (fade out)
            local progress = pulse.elapsed / pulse.duration
            pulse.alpha = 0.6 * (1 - progress)
            i = i + 1
        end
    end
end

function GameplayScene:draw()
    -- Draw background
    love.graphics.clear(0.05, 0.05, 0.1)

    -- Draw starfield behind everything
    for _, star in ipairs(self.starfield) do
        love.graphics.setColor(star.brightness, star.brightness, star.brightness)
        love.graphics.points(star.x, star.y)
    end

    if self.backgroundImage then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(self.backgroundImage, 0, 0)
    end

    -- Draw pulse effects (behind everything)
    for _, pulse in ipairs(self.pulseEffects) do
        love.graphics.setColor(0.3, 0.8, 1, pulse.alpha)
        love.graphics.circle("line", pulse.x, pulse.y, pulse.radius)
        love.graphics.setColor(0.3, 0.8, 1, pulse.alpha * 0.3)
        love.graphics.circle("fill", pulse.x, pulse.y, pulse.radius)
    end

    -- Draw collectibles (yellow)
    love.graphics.setColor(Constants.COLORS.COLLECTIBLE)
    self.collectiblePool:draw()

    -- Draw MOBs with appropriate colors (white flash on hit)
    for _, mob in ipairs(self.mobs) do
        if mob.active or mob.isDying then
            if mob.isFlashing then
                love.graphics.setColor(1, 1, 1)
            elseif mob.emits then
                love.graphics.setColor(Constants.COLORS.SHOOTER_MOB)
            else
                love.graphics.setColor(Constants.COLORS.MELEE_MOB)
            end
            mob:draw()
        end
    end

    -- Draw boss (with distinct color, white flash on hit)
    if self.boss and self.boss.active then
        if self.boss.isFlashing then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(1, 0.5, 0)
        end
        self.boss:draw()
    end

    -- Draw station (cyan, or tinted if debuffed)
    if self.controlInversion then
        love.graphics.setColor(0.3, 1, 0.5)  -- Green tint when scrambled
    elseif self.slowEffect then
        love.graphics.setColor(0.5, 0.5, 1)  -- Purple tint when slowed
    elseif self.fireRateDebuff then
        love.graphics.setColor(1, 0.7, 0.3)  -- Orange tint when jammed
    else
        love.graphics.setColor(Constants.COLORS.STATION)
    end
    self.station:draw()
    self.station:drawTools()

    -- Draw shield
    self.station:drawShield()

    -- Draw player projectiles (blue-cyan)
    love.graphics.setColor(Constants.COLORS.PLAYER_PROJECTILE)
    self.projectilePool:draw()

    -- Draw enemy projectiles (orange)
    love.graphics.setColor(Constants.COLORS.ENEMY_PROJECTILE)
    self.enemyProjectilePool:draw()

    -- Reset color
    love.graphics.setColor(1, 1, 1)

    -- Draw MOB health bars
    for _, mob in ipairs(self.mobs) do
        if mob.active then
            mob:drawHealthBar()
        end
    end

    -- Draw boss health bar (overlays on HUD)
    if self.boss and self.boss.active then
        self.boss:drawHealthBar()
    end

    -- Draw VFX world-space effects (hit flashes, death effects, floating text)
    VFXManager:drawWorld()

    -- Slow effect visual overlay
    if self.slowEffect then
        love.graphics.setColor(0.3, 0.1, 0.5, 0.15)
        love.graphics.rectangle("fill", 0, 0, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT)
    end

    -- Fire rate debuff visual overlay
    if self.fireRateDebuff then
        love.graphics.setColor(1.0, 0.5, 0.0, 0.12)
        love.graphics.rectangle("fill", 0, 0, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT)
    end

    -- Control inversion visual overlay
    if self.controlInversion then
        love.graphics.setColor(0.0, 1.0, 0.3, 0.12)
        love.graphics.rectangle("fill", 0, 0, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT)
    end

    -- Draw HUD
    self:drawHUD()

    -- Draw upgrade selection UI (on top of everything)
    if self.isLevelingUp and UpgradeSelection then
        UpgradeSelection:draw()
    end

    -- Draw slot picker UI (on top of everything)
    if self.isPlacingTool and SlotPicker then
        SlotPicker:draw()
    end

    -- Draw pause menu (on top of everything)
    if self.isPaused and PauseMenu then
        PauseMenu:draw()
    end
end

function GameplayScene:drawHUD()
    -- RP Bar (top of screen)
    local rpPercent = GameManager:getRPPercent()

    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, Constants.SCREEN_WIDTH, 6)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 1, 1, (Constants.SCREEN_WIDTH - 2) * rpPercent, 4)

    -- Top info bar background
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 6, Constants.SCREEN_WIDTH, 18)
    love.graphics.setColor(0, 0, 0)
    love.graphics.line(0, 24, Constants.SCREEN_WIDTH, 24)

    -- Timer (top left)
    local timeStr = Utils.formatTime(self.elapsedTime)
    love.graphics.print(timeStr, 8, 8)

    -- Wave (top center)
    local waveStr = "Wave " .. self.currentWave
    local waveWidth = love.graphics.getFont():getWidth(waveStr)
    love.graphics.print(waveStr, Constants.SCREEN_WIDTH / 2 - waveWidth / 2, 8)

    -- Mob count (between wave and level)
    local mobCount = #self.mobs
    if self.boss and self.boss.active then
        mobCount = mobCount + 1
    end
    local mobStr = "x" .. mobCount
    love.graphics.setColor(0.4, 0.4, 0.5)
    love.graphics.print(mobStr, Constants.SCREEN_WIDTH / 2 + waveWidth / 2 + 8, 8)
    love.graphics.setColor(0, 0, 0)

    -- Level (top right)
    local lvlStr = "Lv." .. GameManager.playerLevel
    local lvlWidth = love.graphics.getFont():getWidth(lvlStr)
    love.graphics.print(lvlStr, Constants.SCREEN_WIDTH - lvlWidth - 8, 8)

    -- Bottom HUD bar
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, Constants.SCREEN_HEIGHT - 22, Constants.SCREEN_WIDTH, 22)
    love.graphics.setColor(0, 0, 0)
    love.graphics.line(0, Constants.SCREEN_HEIGHT - 22, Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT - 22)

    -- Debuff indicators
    local debuffX = 8
    if self.slowEffect then
        love.graphics.setColor(0.5, 0.2, 1)
        love.graphics.print("SLOWED", debuffX, Constants.SCREEN_HEIGHT - 18)
        debuffX = debuffX + love.graphics.getFont():getWidth("SLOWED") + 8
    end
    if self.fireRateDebuff then
        love.graphics.setColor(1, 0.5, 0)
        love.graphics.print("JAMMED", debuffX, Constants.SCREEN_HEIGHT - 18)
        debuffX = debuffX + love.graphics.getFont():getWidth("JAMMED") + 8
    end
    if self.controlInversion then
        love.graphics.setColor(0, 1, 0.3)
        love.graphics.print("SCRAMBLED", debuffX, Constants.SCREEN_HEIGHT - 18)
        debuffX = debuffX + love.graphics.getFont():getWidth("SCRAMBLED") + 8
    end

    -- Active bonus items count
    local itemCount = BonusItemsSystem and BonusItemsSystem:getActiveItemCount() or 0
    if itemCount > 0 then
        love.graphics.setColor(0.2, 0.8, 0.4)
        love.graphics.print("+" .. itemCount, debuffX, Constants.SCREEN_HEIGHT - 18)
    end

    -- Equipped tools display (centered in bottom bar)
    if self.station and self.station.tools then
        local toolCount = #self.station.tools
        local toolDisplayX = Constants.SCREEN_WIDTH / 2 - (toolCount * 12) / 2
        local toolDisplayY = Constants.SCREEN_HEIGHT - 19
        for i, tool in ipairs(self.station.tools) do
            local tx = toolDisplayX + (i - 1) * 12
            if tool.data and tool.data.id then
                -- Use iconPath from tool data for proper fallback handling
                local path
                if tool.data.iconPath then
                    path = tool.data.iconPath .. ".png"
                    path = path:gsub("assets/images/tools/", "assets/images/icons_on_white/")
                else
                    path = "assets/images/icons_on_white/tool_" .. tool.data.id .. ".png"
                end
                local icon = Utils.getCachedIcon(path)
                if icon then
                    local scale = 10 / icon:getWidth()
                    love.graphics.setColor(0, 0, 0)
                    love.graphics.draw(icon, tx, toolDisplayY, 0, scale, scale)
                end
            end
        end
    end

    -- Shield Bar (above health bar)
    if self.station then
        local shieldBarWidth = 100
        local shieldBarHeight = 4
        local shieldBarX = Constants.SCREEN_WIDTH - shieldBarWidth - 8
        local shieldBarY = Constants.SCREEN_HEIGHT - 28

        -- Border
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", shieldBarX - 1, shieldBarY - 1, shieldBarWidth + 2, shieldBarHeight + 2)

        -- Fill
        if self.station.shieldCooldown > 0 then
            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.rectangle("fill", shieldBarX, shieldBarY,
                shieldBarWidth * self.station.shieldOpacity, shieldBarHeight)
        else
            love.graphics.setColor(0, 0.8, 1.0)
            love.graphics.rectangle("fill", shieldBarX, shieldBarY,
                shieldBarWidth * self.station:getShieldPercent(), shieldBarHeight)
        end

        -- Label
        love.graphics.setColor(0.6, 0.6, 0.7)
        love.graphics.print("SH", shieldBarX - 18, shieldBarY - 2)
    end

    -- Health Bar (bottom right)
    local healthBarWidth = 100
    local healthBarHeight = 12
    local healthBarX = Constants.SCREEN_WIDTH - healthBarWidth - 8
    local healthBarY = Constants.SCREEN_HEIGHT - 18

    local healthPercent = self.station:getHealthPercent()

    -- Health bar border
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", healthBarX - 1, healthBarY - 1, healthBarWidth + 2, healthBarHeight + 2)

    -- Health bar background
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", healthBarX, healthBarY, healthBarWidth, healthBarHeight)

    -- Health bar fill
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", healthBarX, healthBarY, healthBarWidth * healthPercent, healthBarHeight)

    -- Health text
    local healthStr = math.floor(self.station.health) .. "/" .. self.station.maxHealth
    local healthWidth = love.graphics.getFont():getWidth(healthStr)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(healthStr, healthBarX - healthWidth - 6, healthBarY)
end

function GameplayScene:exit()
    print("Exiting gameplay scene")

    if AudioManager then
        AudioManager:stopMusic()
    end

    -- Clean up pools
    if self.projectilePool then
        self.projectilePool:releaseAll()
    end
    if self.collectiblePool then
        self.collectiblePool:releaseAll()
    end
    if self.enemyProjectilePool then
        self.enemyProjectilePool:releaseAll()
    end

    -- Clear effects
    self.pulseEffects = {}
    self.slowEffect = false
    self.fireRateDebuff = false
    self.controlInversion = false
    InputManager:setControlInversion(false)
end

return GameplayScene
