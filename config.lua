Config = {}

-- UI & skills
Config.ToggleCommand = 'toggleskills'
Config.ShowNotifications = true
Config.XPIntervalSeconds = 30
Config.MaxSkill = 100

-- Movement
Config.MaxSpeedMultiplier = 1.5 -- cap run speed to 1.5x

-- Dealers (no blips; press E within radius)
Config.Dealers = {
    { coords = vector3(-1195.969, -1577.768, 4.611), radius = 2.0, fee = 175, duration = 3000, xp = 1, skill = 'stamina' },
    { coords = vector3(1392.56, 3607.74, 34.98),     radius = 2.0, fee = 175, duration = 3000, xp = 1, skill = 'stamina' },
    { coords = vector3(-3169.27, 1046.58, 20.86),    radius = 2.0, fee = 175, duration = 3000, xp = 1, skill = 'stamina' },
    { coords = vector3(1690.06, 2592.55, 45.92),     radius = 2.0, fee = 175, duration = 3000, xp = 1, skill = 'stamina' },
}
Config.DealScenario = 'WORLD_HUMAN_STAND_MOBILE' -- phone while calling dealer
Config.InjectionDuration = 5000                   -- 5 seconds locked
Config.BuyCooldown = 15                           -- seconds between buys

-- Anti-spam (server-side)
Config.SpamAttempts = 5
Config.SpamWindow = 5
Config.SpamKickReason = "Stop spamming steroids."

-- Gym settings
Config.EnableGymBlips = true
Config.GymCooldown = 20           -- seconds cooldown per exercise spot
Config.GymDuration = 40000        -- ms player is locked doing the exercise
Config.GymXP = 1                  -- strength XP granted per completed exercise

-- Gym spots (type: pushups/situps/yoga/chinups/weights)
Config.GymSpots = {
    { type = 'pushups', coords = vector3(-1203.35, -1565.39, 4.61) },
    { type = 'situps',  coords = vector3(-1205.15, -1567.64, 4.61) },
    { type = 'chinups', coords = vector3(-1200.00, -1577.00, 4.61) }
}

-- Blip appearance
Config.GymBlip = { sprite = 311, color = 1, scale = 0.8, name = 'Gym' }
