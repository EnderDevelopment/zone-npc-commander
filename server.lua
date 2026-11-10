local ESX
local zoneData = {}
local savedRevision = 0

CreateThread(function()
    if GetResourceState('es_extended') == 'started' then ESX = exports['es_extended']:getSharedObject() end
    local raw = GetResourceKvpString(Config.KvpKey)
    if raw then
        local ok, decoded = pcall(json.decode, raw)
        if ok and type(decoded) == 'table' then zoneData = decoded end
    end
end)

local function isAdmin(src)
    if src == 0 then return true end
    if IsPlayerAceAllowed(src, Config.AcePermission) then return true end
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            local group = xPlayer.getGroup and xPlayer.getGroup()
            for _, allowed in ipairs(Config.AdminGroups) do if group == allowed then return true end end
        end
    end
    return false
end

local function notify(src, message) TriggerClientEvent('ender_npczones:notify', src, message) end

local function saveData()
    savedRevision = savedRevision + 1
    SetResourceKvp(Config.KvpKey, json.encode(zoneData))
    TriggerClientEvent('ender_npczones:sync', -1, zoneData, savedRevision)
end

local function validZone(zone)
    if type(zone) ~= 'table' or type(zone.id) ~= 'string' or #zone.id > 64 or type(zone.name) ~= 'string' or #zone.name > 40 then return false end
    if type(zone.coords) ~= 'table' or not tonumber(zone.coords.x) or not tonumber(zone.coords.y) or not tonumber(zone.coords.z) then return false end
    if type(zone.groups) ~= 'table' or #zone.groups < 1 or #zone.groups > 20 then return false end
    zone.radius = math.max(10.0, math.min(tonumber(zone.radius) or 50.0, 500.0))
    local allowedModels, allowedWeapons = {}, {}
    for _, entry in ipairs(Config.Models) do allowedModels[entry.model] = true end
    for _, weapon in ipairs(Config.Weapons) do allowedWeapons[weapon] = true end
    for _, group in ipairs(zone.groups) do
        if type(group) ~= 'table' or not allowedModels[group.model] or not allowedWeapons[group.weapon] then return false end
        if not ({ patrol = true, wander = true, attack = true, air = true })[group.behavior] then return false end
        group.count = math.max(1, math.min(math.floor(tonumber(group.count) or 1), Config.MaxNPCsPerZone))
        group.accuracy = math.max(0, math.min(math.floor(tonumber(group.accuracy) or Config.DefaultAccuracy), 100))
    end
    zone.coords = { x = tonumber(zone.coords.x), y = tonumber(zone.coords.y), z = tonumber(zone.coords.z), heading = tonumber(zone.coords.heading) or 0.0 }
    return true
end

RegisterNetEvent('ender_npczones:requestSync', function() TriggerClientEvent('ender_npczones:sync', source, zoneData, savedRevision) end)
RegisterNetEvent('ender_npczones:requestAdmin', function()
    local src = source
    if not isAdmin(src) then notify(src, 'You do not have permission to manage NPC zones.'); return end
    TriggerClientEvent('ender_npczones:openAdmin', src, zoneData, Config.Models, Config.Weapons)
end)

RegisterNetEvent('ender_npczones:saveZone', function(zone)
    local src = source
    if not isAdmin(src) then notify(src, 'You do not have permission.'); return end
    if not validZone(zone) then notify(src, 'Invalid zone data.'); return end
    local found = false
    for i, existing in ipairs(zoneData) do
        if existing.id == zone.id then zoneData[i] = zone; found = true; break end
    end
    if not found then
        if #zoneData >= Config.MaxZones then notify(src, 'Zone limit reached.'); return end
        zoneData[#zoneData + 1] = zone
    end
    saveData(); notify(src, 'Zone saved.')
end)

RegisterNetEvent('ender_npczones:deleteZone', function(id)
    local src = source
    if not isAdmin(src) then notify(src, 'You do not have permission.'); return end
    if type(id) ~= 'string' then return end
    for i, zone in ipairs(zoneData) do
        if zone.id == id then table.remove(zoneData, i); saveData(); notify(src, 'Zone deleted.'); return end
    end
end)

RegisterCommand(Config.Command, function(src)
    if src == 0 then return end
    if not isAdmin(src) then notify(src, 'You do not have permission to manage NPC zones.'); return end
    TriggerClientEvent('ender_npczones:openAdmin', src, zoneData, Config.Models, Config.Weapons)
end, false)

AddEventHandler('playerJoining', function()
    local src = source
    SetTimeout(2000, function() if GetPlayerName(src) then TriggerClientEvent('ender_npczones:sync', src, zoneData, savedRevision) end end)
end)

exports('GetZones', function() return zoneData end)
exports('ReloadZones', function() TriggerClientEvent('ender_npczones:sync', -1, zoneData, savedRevision) end)
