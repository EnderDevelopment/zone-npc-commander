Config = {}

Config.Locale = 'en'
Config.Command = 'npczones'
Config.AdminGroups = { 'admin', 'superadmin' }
Config.AcePermission = 'ender_npczones.admin'
Config.MaxZones = 50
Config.MaxNPCsPerZone = 30
Config.InteractDistance = 3.0
Config.SpawnDistance = 250.0
Config.DespawnDistance = 350.0
Config.SyncInterval = 5000
Config.KvpKey = 'ender_npczones:data:v1'
Config.DefaultWeapon = 'WEAPON_PISTOL'
Config.DefaultAccuracy = 20
Config.Models = {
    { label = 'Army Soldier', model = 's_m_y_soldier_01' },
    { label = 'Army Soldier 2', model = 's_m_y_marine_01' },
    { label = 'Army Soldier 3', model = 's_m_y_marine_03' },
    { label = 'Army Officer', model = 's_m_y_armymech_01' },
    { label = 'Merryweather Guard', model = 's_m_y_blackops_01' },
    { label = 'Black Ops Soldier', model = 's_m_y_blackops_02' },
    { label = 'Black Ops Heavy', model = 's_m_y_blackops_03' },
    { label = 'Biker', model = 'g_m_y_lost_01' },
    { label = 'Lost MC Biker 2', model = 'g_m_y_lost_02' },
    { label = 'Lost MC Biker 3', model = 'g_m_y_lost_03' },
    { label = 'Biker Female', model = 'g_f_y_lost_01' },
    { label = 'Security Guard', model = 's_m_m_security_01' },
    { label = 'Police Officer', model = 's_m_y_cop_01' },
    { label = 'Gang Member', model = 'g_m_y_mexgoon_01' },
    { label = 'Mercenary', model = 's_m_y_blackops_01' },
    { label = 'Private Security', model = 's_m_m_armoured_01' }
}
Config.Weapons = {
    'WEAPON_UNARMED', 'WEAPON_PISTOL', 'WEAPON_COMBATPISTOL', 'WEAPON_PISTOL50',
    'WEAPON_SMG', 'WEAPON_ASSAULTRIFLE', 'WEAPON_CARBINERIFLE', 'WEAPON_SPECIALCARBINE',
    'WEAPON_PUMPSHOTGUN', 'WEAPON_SAWNOFFSHOTGUN', 'WEAPON_SNIPERRIFLE', 'WEAPON_MICROSMG',
    'WEAPON_KNIFE', 'WEAPON_BAT', 'WEAPON_CROWBAR'
}
