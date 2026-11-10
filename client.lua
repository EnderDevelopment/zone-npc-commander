local zones, models, weapons = {}, {}, {}
local spawned = {}
local populationOwner = false

local function notify(message)
    BeginTextCommandThefeedPost('STRING'); AddTextComponentSubstringPlayerName(message); EndTextCommandThefeedPostTicker(false, false)
end

local function electOwner()
    local players = GetActivePlayers()
    table.sort(players, function(a, b) return GetPlayerServerId(a) < GetPlayerServerId(b) end)
    populationOwner = players[1] == PlayerId()
end

electOwner()
RegisterNetEvent('playerJoining', function() Wait(500); electOwner() end)
RegisterNetEvent('playerDropped', function() Wait(500); electOwner() end)
RegisterNetEvent('ender_npczones:notify', notify)
RegisterNetEvent('ender_npczones:sync', function(data) zones = data or {} end)
RegisterNetEvent('ender_npczones:openAdmin', function(data, modelList, weaponList)
    zones, models, weapons = data or {}, modelList or {}, weaponList or {}
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', zones = zones, models = models, weapons = weapons })
end)

RegisterCommand(Config.Command, function() TriggerServerEvent('ender_npczones:requestAdmin') end, false)
RegisterNetEvent('esx:playerLoaded', function() TriggerServerEvent('ender_npczones:requestSync') end)
CreateThread(function() Wait(1500); TriggerServerEvent('ender_npczones:requestSync') end)

RegisterNUICallback('close', function(_, cb) SetNuiFocus(false, false); cb({ ok = true }) end)
RegisterNUICallback('save', function(data, cb) TriggerServerEvent('ender_npczones:saveZone', data.zone); cb({ ok = true }) end)
RegisterNUICallback('delete', function(data, cb) TriggerServerEvent('ender_npczones:deleteZone', data.id); cb({ ok = true }) end)
RegisterNUICallback('telemetry', function(data, cb)
    if data and data.action == 'position' then
        local ped, p = PlayerPedId(), GetEntityCoords(PlayerPedId())
        SendNUIMessage({ action = 'position', coords = { x = p.x, y = p.y, z = p.z, heading = GetEntityHeading(ped) } })
    end
    cb({ ok = true })
end)

local function loadModel(name)
    local hash = joaat(name)
    if not IsModelInCdimage(hash) or not IsModelValid(hash) then return nil end
    RequestModel(hash)
    local deadline = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < deadline do Wait(50) end
    if not HasModelLoaded(hash) then return nil end
    return hash
end

local function spawnGroup(zone, group, index)
    local key = zone.id .. ':' .. index
    spawned[key] = spawned[key] or {}
    for i = #spawned[key], 1, -1 do if not DoesEntityExist(spawned[key][i]) then table.remove(spawned[key], i) end end
    while #spawned[key] < group.count do
        local hash = loadModel(group.model)
        if not hash then return end
        local angle, radius = math.random() * math.pi * 2, math.random() * math.max(2.0, zone.radius * 0.65)
        local x, y = zone.coords.x + math.cos(angle) * radius, zone.coords.y + math.sin(angle) * radius
        local found, groundZ = GetGroundZFor_3dCoord(x, y, zone.coords.z + 50.0, false)
        local ped = CreatePed(4, hash, x, y, found and groundZ or zone.coords.z, zone.coords.heading or 0.0, true, true)
        SetModelAsNoLongerNeeded(hash)
        if not DoesEntityExist(ped) then break end
        SetEntityAsMissionEntity(ped, true, true)
        SetPedAccuracy(ped, group.accuracy or Config.DefaultAccuracy)
        SetPedDropsWeaponsWhenDead(ped, false)
        SetPedFleeAttributes(ped, 0, false)
        SetPedCombatAttributes(ped, 46, true)
        SetPedCombatAbility(ped, 2)
        SetPedCombatRange(ped, 2)
        if group.weapon and group.weapon ~= 'WEAPON_UNARMED' then
            GiveWeaponToPed(ped, joaat(group.weapon), 250, false, true)
            SetCurrentPedWeapon(ped, joaat(group.weapon), true)
        end
        if group.behavior == 'patrol' then
            TaskWanderInArea(ped, zone.coords.x, zone.coords.y, zone.coords.z, zone.radius, 2.0, 8.0)
        elseif group.behavior == 'wander' then
            TaskWanderStandard(ped, 10.0, 10)
        elseif group.behavior == 'air' then
            TaskShooting(ped, zone.coords.x, zone.coords.y, zone.coords.z + 80.0, 2000, joaat('FIRING_PATTERN_BURST_FIRE'))
        elseif group.behavior == 'attack' then
            SetPedAsEnemy(ped, true)
            TaskCombatHatedTargetsAroundPed(ped, zone.radius)
        end
        spawned[key][#spawned[key] + 1] = ped
    end
end

local function clearZone(zoneId)
    for key, peds in pairs(spawned) do
        if key:sub(1, #zoneId + 1) == zoneId .. ':' then
            for _, ped in ipairs(peds) do if DoesEntityExist(ped) then DeleteEntity(ped) end end
            spawned[key] = nil
        end
    end
end

CreateThread(function()
    while true do
        if populationOwner then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local active = {}
            for _, zone in ipairs(zones) do
                active[zone.id] = true
                local distance = #(playerCoords - vector3(zone.coords.x, zone.coords.y, zone.coords.z))
                if distance <= Config.SpawnDistance then
                    for i, group in ipairs(zone.groups) do spawnGroup(zone, group, i) end
                elseif distance >= Config.DespawnDistance then clearZone(zone.id) end
            end
            for key in pairs(spawned) do
                local zoneId = key:match('^(.-):%d+$')
                if zoneId and not active[zoneId] then clearZone(zoneId) end
            end
        else
            for _, peds in pairs(spawned) do for _, ped in ipairs(peds) do if DoesEntityExist(ped) then DeleteEntity(ped) end end end
            spawned = {}
        end
        Wait(Config.SyncInterval)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    SetNuiFocus(false, false)
    for _, peds in pairs(spawned) do for _, ped in ipairs(peds) do if DoesEntityExist(ped) then DeleteEntity(ped) end end end
end)
