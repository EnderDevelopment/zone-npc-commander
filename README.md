# FiveM NPC Zone Management Resource

Zone NPC Commander is a FiveM resource for ESX Legacy that lets authorized admins create and manage NPC zones and groups through an in-game NUI menu. Configure NPC models, weapons, group sizes, accuracy, zone radius, and behavior, then save zones for persistent use.

## Install

1. Copy the resource folder into your server’s resources directory.
2. Add `ensure ender_npczones` to `server.cfg`, after `ensure es_extended`.
3. Grant admins either an ESX group listed in `Config.AdminGroups` or the ACE permission `ender_npczones.admin`.
4. Start or restart the server.

## Use

1. In game, run `/npczones` as an authorized admin.
2. Create a zone, set its name and radius, and enter coordinates or use your current position.
3. Add one or more NPC groups. Choose a model, weapon, behavior, group size, and accuracy.
4. Save the zone. Zone data is stored in the resource’s server KVP and synced to clients.
5. NPCs spawn when the population-owning client is within the configured spawn distance and are removed after moving beyond the despawn distance.

---

More FiveM resource projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/b4ff366b-73d0-41e1-ad4b-a095c859ec6e?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=b4ff366b-73d0-41e1-ad4b-a095c859ec6e
