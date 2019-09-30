# Space Game

A six-degrees-of-freedom shooter in the vein of old space sims like X-Wing and Freespace. The purpose of this project is to document my journey making a game from start to finish.

## Features

Here I'll be keeping track of the all the features I want to implement, and check them off as I include them.

- [x] Panorama Sky
- [x] Player-controlled spaceship
- [x] Basic Energy Weapons
- [x] Hull Damage
- [x] Shield Damage
- [ ] Head's Up Display (HUD)
- [ ] Power Distribution
- [ ] Reroute power to Shields by quadrant
- [ ] Alliance Groups
- [ ] Title Screen
- [ ] Options Menu
- [ ] Mission Objectives and Warp Out
- [ ] Communications Menu (in-game)
- [ ] Wingmen
- [ ] Mission Briefing
- [ ] Loadout Menu
- [ ] Capital Ships
- [ ] Carrier Ships

### Optional Features

I'd like to implement these, but I'm not sure whether they're feasible.

- [ ] Customize HUD Colors
- [ ] Custom Ships users can import
- [ ] Mission Editor

## Feature Descriptions

Here are some more in-depth descriptions for certain features.

- Power Distribution: Allocate power between Energy Weapons Battery, Shield Power, and Engine Power. Energy Weapons Battery determines how quickly energy weapons power recovers (maybe also the maximum battery too?) Shield Power determines recovery rate (maybe also max strength?) Engine Power determines acceleration and max speed.
- Alliance Groups: Every ship belongs to a designated group (probably best to default to a given group). Each group just contains a mapping to every other group determining its alliances with other groups. We then use each ship's group to determine whether they're allied with, neutral to, or an enemy of other ships.
- Mission Objectives and Warp Out: Once all critical objectives are complete, the player warps out to end the mission.
- Communications Menu: This is a staple of old space games, used to issue orders to wingmen, call in reinforcements, request repairs/reloading, and more.
- Loadout Menu: The player chooses their ship and loadout before launching the mission.
- Carrier Ships: Ship that can launch small ships (fighters/bombers.) Maybe the player can land there to repair/reload?

## Mission Objectives

There are three categories for mission objectives: Primary, Secondary, and Secret.

- Primary: These are typically critical for mission success, and result in mission failure if even one is failed. If not marked as critical, it can be allowed to fail, maybe for story reasons.
- Secondary: These are non-critical objectives that will give the player an advantage of some kind in either the next mission or a future one, like an additional wing of ships, reduced enemy presence, etc.
- Secret: Unlike Primary and Secondary Objectives, Secret Objectives are not visible from the briefing menu, and only appear once special conditions are met during the mission. These can unlock ships/weapons early, as well as ship skins or alternate models maybe?
