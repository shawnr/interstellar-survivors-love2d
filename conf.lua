-- Love2D Configuration
-- Interstellar Survivors port

function love.conf(t)
    -- Identity
    t.identity = "interstellar-survivors"
    t.version = "11.4"  -- Love2D version

    -- Window
    t.window.title = "Interstellar Survivors"
    t.window.width = 800   -- 2x native (400)
    t.window.height = 480  -- 2x native (240)
    t.window.resizable = true
    t.window.minwidth = 400
    t.window.minheight = 240
    t.window.vsync = 1

    -- Modules (enable only what we need)
    t.modules.audio = true
    t.modules.data = true
    t.modules.event = true
    t.modules.font = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.sound = true
    t.modules.system = true
    t.modules.timer = true
    t.modules.window = true

    -- Disable unused modules
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.thread = false
    t.modules.touch = false
    t.modules.video = false
end
