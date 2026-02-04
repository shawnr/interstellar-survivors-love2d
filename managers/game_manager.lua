-- Game Manager
-- Handles game state, player progression, and scene transitions

GameManager = {
    -- Game states
    states = {
        TITLE = "title",
        EPISODE_INTRO = "episode_intro",
        GAMEPLAY = "gameplay",
        EPISODE_ENDING = "episode_ending",
        RESULTS = "results",
        GRANTS = "grants",
        SPECS = "specs",
        CODEX = "codex",
        SETTINGS = "settings",
    },

    -- Current state
    currentState = nil,

    -- Episode tracking
    currentEpisodeId = 1,
    currentEpisodeData = nil,

    -- Player progression (per-run)
    playerLevel = 1,
    currentRP = 0,
    totalRP = 0,
    rpToNextLevel = 50,

    -- Game stats (per-run, displayed on results screen)
    gameStats = nil,

    -- Results context
    lastResultIsVictory = false,
}

function GameManager:init()
    self.currentState = nil
    self.currentEpisodeId = 1
    self.currentEpisodeData = nil
    self.playerLevel = 1
    self.currentRP = 0
    self.totalRP = 0
    self.rpToNextLevel = Utils.xpToNextLevel(self.playerLevel)
    self.gameStats = nil
    self.lastResultIsVictory = false

    print("GameManager initialized")
end

function GameManager:setState(newState, params)
    local oldState = self.currentState
    self.currentState = newState

    print("GameManager: " .. tostring(oldState) .. " -> " .. tostring(newState))

    if newState == self.states.TITLE then
        if TitleScene then
            TitleScene:enter(params)
        end
    elseif newState == self.states.EPISODE_INTRO then
        if StoryScene then
            StoryScene:enter(params)
        end
    elseif newState == self.states.GAMEPLAY then
        if GameplayScene then
            GameplayScene:enter(params)
        end
    elseif newState == self.states.EPISODE_ENDING then
        if StoryScene then
            StoryScene:enter(params)
        end
    elseif newState == self.states.RESULTS then
        if ResultsScene then
            ResultsScene:enter(params)
        end
    elseif newState == self.states.GRANTS then
        if GrantsScene then
            GrantsScene:enter(params)
        end
    elseif newState == self.states.SPECS then
        if SpecsScene then
            SpecsScene:enter(params)
        end
    elseif newState == self.states.CODEX then
        if CodexScene then
            CodexScene:enter(params)
        end
    elseif newState == self.states.SETTINGS then
        if SettingsScene then
            SettingsScene:enter(params)
        end
    end
end

-- Transition to a new state with fade effect
function GameManager:transitionTo(newState, params)
    if VFXManager then
        VFXManager:startTransition(
            Constants.VFX.TRANSITION_FADE_SPEED,
            function()
                self:setState(newState, params)
            end,
            Constants.VFX.TRANSITION_FADE_SPEED
        )
    else
        self:setState(newState, params)
    end
end

-- Go to title screen
function GameManager:goToTitle()
    self:transitionTo(self.states.TITLE)
end

-- Start an episode (intro -> gameplay -> ending -> results)
function GameManager:startEpisode(episodeId)
    self.currentEpisodeId = episodeId or 1
    self.currentEpisodeData = EpisodesData.get(self.currentEpisodeId)

    -- Reset per-run state
    self.playerLevel = 1
    self.currentRP = 0
    self.totalRP = 0
    self.rpToNextLevel = Utils.xpToNextLevel(self.playerLevel)
    self.gameStats = {
        mobKills = 0,
        totalRP = 0,
        elapsedTime = 0,
        levelReached = 1,
        toolsEquipped = 0,
    }

    -- Show intro panels if available
    if self.currentEpisodeData and self.currentEpisodeData.introPanels and #self.currentEpisodeData.introPanels > 0 then
        self:setState(self.states.EPISODE_INTRO, {
            panels = self.currentEpisodeData.introPanels,
            onComplete = function()
                self:startGameplay()
            end
        })
    else
        self:startGameplay()
    end
end

-- Start gameplay (called after intro or directly)
function GameManager:startGameplay()
    self:transitionTo(self.states.GAMEPLAY, {
        episodeId = self.currentEpisodeId,
        episodeData = self.currentEpisodeData,
    })
end

-- Called when station is destroyed
function GameManager:onStationDestroyed()
    -- Collect stats from gameplay
    self:collectGameStats()
    self:showResults(false)
end

-- Called when boss is defeated
function GameManager:onBossDefeated()
    -- Collect stats from gameplay
    self:collectGameStats()

    -- Mark episode complete
    if SaveManager then
        SaveManager:completeEpisode(self.currentEpisodeId)
    end

    -- Show ending panels if available
    if self.currentEpisodeData and self.currentEpisodeData.endingPanels and #self.currentEpisodeData.endingPanels > 0 then
        -- Exit gameplay first
        if GameplayScene then
            GameplayScene:exit()
        end

        self:setState(self.states.EPISODE_ENDING, {
            panels = self.currentEpisodeData.endingPanels,
            onComplete = function()
                self:showResults(true)
            end
        })
    else
        self:showResults(true)
    end
end

-- Show results screen
function GameManager:showResults(isVictory)
    self.lastResultIsVictory = isVictory

    -- Persist earned RP
    if SaveManager and self.totalRP > 0 then
        SaveManager:earnRP(self.totalRP)
    end

    -- Track victory/death
    if SaveManager then
        if isVictory then
            SaveManager:incrementVictories()
        else
            SaveManager:incrementDeaths()
        end
    end

    -- Exit gameplay if still active
    if self.currentState == self.states.GAMEPLAY and GameplayScene then
        GameplayScene:exit()
    end

    self:transitionTo(self.states.RESULTS, {
        isVictory = isVictory,
        episodeData = self.currentEpisodeData,
        stats = self.gameStats,
    })
end

-- Collect stats from gameplay scene
function GameManager:collectGameStats()
    if not self.gameStats then
        self.gameStats = {}
    end

    self.gameStats.levelReached = self.playerLevel
    self.gameStats.totalRP = self.totalRP

    if GameplayScene then
        self.gameStats.elapsedTime = GameplayScene.elapsedTime or 0
        self.gameStats.mobKills = GameplayScene.stats and GameplayScene.stats.mobKills or 0
        self.gameStats.toolsEquipped = GameplayScene.station and #GameplayScene.station.tools or 0
    end
end

-- Award research points (XP)
function GameManager:awardRP(amount)
    -- Apply RP multipliers from meta-progression
    if GrantsSystem then
        amount = amount * GrantsSystem:getRPMultiplier()
    end
    if SpecsSystem then
        amount = amount * (1 + SpecsSystem:getRPBonus())
    end
    if BonusItemsSystem then
        amount = amount * (1 + BonusItemsSystem:getRPBonus())
    end

    self.currentRP = self.currentRP + amount
    self.totalRP = self.totalRP + amount

    -- Check for level up
    while self.currentRP >= self.rpToNextLevel do
        self.currentRP = self.currentRP - self.rpToNextLevel
        self:levelUp()
    end
end

-- Level up the player
function GameManager:levelUp()
    self.playerLevel = self.playerLevel + 1
    self.rpToNextLevel = Utils.xpToNextLevel(self.playerLevel)

    print("LEVEL UP! Now level " .. self.playerLevel)

    -- Notify gameplay scene
    if GameplayScene and GameplayScene.onLevelUp then
        GameplayScene:onLevelUp()
    end
end

-- Get current RP percentage (0-1)
function GameManager:getRPPercent()
    if self.rpToNextLevel <= 0 then return 0 end
    return self.currentRP / self.rpToNextLevel
end

-- Legacy compatibility
function GameManager:startNewEpisode(episodeId)
    self:startEpisode(episodeId)
end

return GameManager
