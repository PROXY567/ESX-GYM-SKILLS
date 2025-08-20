ESX = exports['es_extended']:getSharedObject()

local staminaXP, strengthXP = 0, 0
local showUI = false
local lastBuy = 0.0
local spotCooldowns = {}

-- ===== Helpers =====
local function Draw3DText(x, y, z, text)
    local onScreen,_x,_y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.30, 0.30)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextOutline()
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- ===== Load/Update =====
RegisterNetEvent('proxy:client:load', function(data)
    staminaXP = data.stamina or 0
    strengthXP = data.strength or 0
    if Config.ShowNotifications then
        ESX.ShowNotification(('Skills loaded: Stamina %s | Strength %s'):format(staminaXP, strengthXP))
    end
end)

RegisterNetEvent('proxy:client:update', function(data)
    if data.stamina ~= nil then staminaXP = data.stamina end
    if data.strength ~= nil then strengthXP = data.strength end
    if Config.ShowNotifications and data.note and (staminaXP < Config.MaxSkill or strengthXP < Config.MaxSkill) then
        ESX.ShowNotification(data.note)
    end
end)

-- ===== Toggle HUD (placeholder) =====
RegisterCommand(Config.ToggleCommand, function()
    showUI = not showUI
    ESX.ShowNotification("Skill HUD " .. (showUI and "~g~Enabled" or "~r~Disabled"))
end)

-- ===== Periodic XP gain =====
CreateThread(function()
    local interval = math.max(5, Config.XPIntervalSeconds)
    while true do
        Wait(interval * 1000)
        local ped = PlayerPedId()
        local onFoot = not IsPedInAnyVehicle(ped, false)
        local vehicle = GetVehiclePedIsUsing(ped)
        local isOnBicycle = (vehicle ~= 0 and GetVehicleClass(vehicle) == 13)

        local staminaActive = IsPedRunning(ped) or IsPedSprinting(ped) or IsPedSwimming(ped) or isOnBicycle
        local strengthActive = onFoot and (IsPedInMeleeCombat(ped) or IsControlPressed(0, 24)) -- LMB

        if staminaActive then TriggerServerEvent('proxy:server:addxp', 'stamina', 1) end
        if strengthActive then TriggerServerEvent('proxy:server:addxp', 'strength', 1) end
    end
end)

-- ===== Movement multipliers based on staminaXP =====
CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local mult = 1.0 + math.min((staminaXP / 100.0) * (Config.MaxSpeedMultiplier - 1.0), (Config.MaxSpeedMultiplier - 1.0))
        if mult > Config.MaxSpeedMultiplier then mult = Config.MaxSpeedMultiplier end
        SetRunSprintMultiplierForPlayer(PlayerId(), mult)
        SetPedMoveRateOverride(ped, mult)
        SetPedDesiredMoveBlendRatio(ped, mult)
        RestorePlayerStamina(PlayerId(), 1.0 + (staminaXP / 100.0) * 0.5)
    end
end)

-- ===== Dealers (press E) =====
CreateThread(function()
    while true do
        local sleep = 800
        local ped = PlayerPedId()
        local pcoords = GetEntityCoords(ped)
        for i, d in ipairs(Config.Dealers) do
            local dist = #(pcoords - d.coords)
            if dist <= 15.0 then
                sleep = 0
                DrawMarker(1, d.coords.x, d.coords.y, d.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.6, 0.6, 0.3, 80, 80, 200, 120, false, true, 2, false, nil, nil, false)
                Draw3DText(d.coords.x, d.coords.y, d.coords.z + 0.2, "[E] Buy Steroids ($" .. d.fee .. ")")
                if dist <= d.radius + 0.5 then
                    if IsControlJustPressed(0, 38) then
                        local now = GetGameTimer() / 1000.0
                        if (now - lastBuy) >= Config.BuyCooldown then
                            lastBuy = now
                            TriggerServerEvent('proxy:server:buy', i)
                        else
                            local left = math.ceil(Config.BuyCooldown - (now - lastBuy))
                            ESX.ShowNotification(('Please wait %ds before buying again.'):format(left))
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-- ===== Dealer Animation: phone -> butt injection (locked 5s) =====
RegisterNetEvent('proxy:client:deal', function(index, duration)
    local ped = PlayerPedId()

    -- Phone call
    TaskStartScenarioInPlace(ped, Config.DealScenario, 0, true)
    local phoneEnd = GetGameTimer() + (duration or 5000)
    while GetGameTimer() < phoneEnd do
        Wait(0)
        DisableControlAction(0, 24, true) -- attack
        DisableControlAction(0, 25, true) -- aim
        DisableControlAction(0, 21, true) -- sprint
        DisableControlAction(0, 22, true) -- jump
        DisableControlAction(0, 30, true) -- move
        DisableControlAction(0, 31, true)
    end
    ClearPedTasks(ped)

    -- Injection
    local dict, anim = "mp_suicide", "pill"
    RequestAnimDict(dict) while not HasAnimDictLoaded(dict) do Wait(0) end

    local prop = CreateObject(GetHashKey("prop_cs_syringe_01"), 0.0, 0.0, 0.0, true, true, true)
    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 11816), 0.0, 0.0, 0.0, 90.0, 0.0, 0.0, true, true, false, true, 1, true)
    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, Config.InjectionDuration, 49, 0.0, false, false, false)

    local injectEnd = GetGameTimer() + Config.InjectionDuration
    while GetGameTimer() < injectEnd do
        Wait(0)
        DisableAllControlActions(0)
        EnableControlAction(0, 1, true) -- look
        EnableControlAction(0, 2, true) -- look
    end
    ClearPedTasks(ped)
    DeleteObject(prop)

    TriggerServerEvent('proxy:server:deal:done', index)
end)

-- ===== Gym Blips =====
CreateThread(function()
    if not Config.EnableGymBlips then return end
    for _, s in ipairs(Config.GymSpots) do
        local blip = AddBlipForCoord(s.coords.x, s.coords.y, s.coords.z)
        SetBlipSprite(blip, Config.GymBlip.sprite or 311)
        SetBlipColour(blip, Config.GymBlip.color or 1)
        SetBlipScale(blip, Config.GymBlip.scale or 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.GymBlip.name or "Gym")
        EndTextCommandSetBlipName(blip)
    end
end)

-- ===== Gym Interaction =====
local exerciseMap = {
    pushups = { scenario = nil, animDict = "amb@world_human_push_ups@male@base", animName = "base" },
    situps  = { scenario = nil, animDict = "amb@world_human_sit_ups@male@base", animName = "base" },
    yoga    = { scenario = "WORLD_HUMAN_YOGA", animDict = nil, animName = nil },
    chinups = { scenario = "PROP_HUMAN_MUSCLE_CHIN_UPS", animDict = nil, animName = nil },
    weights = { scenario = "WORLD_HUMAN_MUSCLE_FREE_WEIGHTS", animDict = nil, animName = nil }
}

local function doExercise(s)
    local ped = PlayerPedId()
    local entry = exerciseMap[s.type]; if not entry then return end

    -- cooldown check
    local key = string.format("%.2f,%.2f,%.2f", s.coords.x, s.coords.y, s.coords.z)
    local now = GetGameTimer()
    if spotCooldowns[key] and now < spotCooldowns[key] then
        local left = math.ceil((spotCooldowns[key] - now) / 1000.0)
        ESX.ShowNotification(("Rest a moment... %ds"):format(left))
        return
    end

    -- start animation/scenario
    if entry.scenario then
        TaskStartScenarioAtPosition(ped, entry.scenario, s.coords.x, s.coords.y, s.coords.z, 0.0, 0, true, true)
    else
        RequestAnimDict(entry.animDict); while not HasAnimDictLoaded(entry.animDict) do Wait(0) end
        TaskPlayAnimAdvanced(ped, entry.animDict, entry.animName, s.coords.x, s.coords.y, s.coords.z, 0.0, 0.0, 0.0, 8.0, -8.0, Config.GymDuration, 1, 0.0, true, true)
    end

    local endTime = GetGameTimer() + Config.GymDuration
    while GetGameTimer() < endTime do
        Wait(0)
        DisableAllControlActions(0)
        EnableControlAction(0, 1, true) -- look
        EnableControlAction(0, 2, true) -- look
    end

    ClearPedTasks(ped)
    TriggerServerEvent('proxy:server:addxp', 'strength', Config.GymXP)
    spotCooldowns[key] = GetGameTimer() + (Config.GymCooldown * 1000)
end

CreateThread(function()
    while true do
        local sleep = 800
        local ped = PlayerPedId()
        local pcoords = GetEntityCoords(ped)
        for _, s in ipairs(Config.GymSpots) do
            local dist = #(pcoords - s.coords)
            if dist <= 15.0 then
                sleep = 0
                DrawMarker(1, s.coords.x, s.coords.y, s.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.6, 0.6, 0.3, 255, 180, 50, 140, false, true, 2, false, nil, nil, false)
                Draw3DText(s.coords.x, s.coords.y, s.coords.z + 0.2, "[E] " .. (s.type or "exercise"):upper())
                if dist <= 1.5 and IsControlJustPressed(0, 38) then
                    doExercise(s)
                end
            end
        end
        Wait(sleep)
    end
end)
