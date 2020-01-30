# Space Game

A six-degrees-of-freedom shooter in the vein of old space sims like X-Wing and Freespace. The purpose of this project is to document my journey making a game from start to finish.

## Features

Here I'll be keeping track of the all the features I want to implement, and check them off as I include them.

- [x] Panorama Sky
- [x] Player-controlled spaceship
- [x] Basic Energy Weapons
- [x] Hull Damage
- [x] Shield Damage
- [x] Head's Up Display (HUD)
- [x] Power Distribution
- [x] Reroute power to Shields by quadrant
- [x] Alliance Groups
- [x] Title Screen
- [x] NPC Ship Behavior
- [x] Communications Menu (in-game)
- [x] Group ships into Wings
- [x] Mission Objectives and Warp Out
- [x] Options Menu
- [x] Mission Briefing
- [x] Loadout Menu
- [x] Pause Menu
- [x] Mission Editor
- [ ] Campaign Tree
- [x] Capital Ships
- [ ] Carrier Ships
- [ ] User Interface Sounds
- [x] Ship/Weapon Sound Effects
- [x] Ship Subsystems
- [x] Lead Indicator
- [x] Eyecatch
- [x] Gallery/Library
- [ ] Music

### Accessibility Options

- [x] Dyslexia-friendly theme
- [x] Colorblindness options

### Optional Features

I'd like to implement these, but I'm not sure whether they're feasible.

- [x] Customize HUD Colors
- [ ] Cockpit Model for each playable ship
- [ ] Custom Ships users can import

## Feature Descriptions

Here are some more in-depth descriptions for certain features.

- __Power Distribution__: Allocate power between Energy Weapons Battery, Shield Power, and Engine Power. Energy Weapons Battery determines how quickly energy weapons power recovers (maybe also the maximum battery too?) Shield Power determines recovery rate (maybe also max strength?) Engine Power determines acceleration and max speed.
- __Alliance Groups__: Every ship belongs to a designated group (probably best to default to a given group). Each group just contains a mapping to every other group determining its alliances with other groups. We then use each ship's group to determine whether they're allied with, neutral to, or an enemy of other ships.
- __Mission Objectives and Warp Out__: Once all critical objectives are complete, the player warps out to end the mission.
- __Communications Menu__: This is a staple of old space games, used to issue orders to wingmen, call in reinforcements, request repairs/reloading, and more.
- __Loadout Menu__: The player chooses their ship and loadout before launching the mission.
- __Campaign Tree__: Missions need to be connected to each other to form a progression. A tree structure will allow for paths that branch off or loop around. Whether the player meets certain objectives during a mission will determine how the following missions will branch and loop.
- __Carrier Ships__: Ship that can launch small ships (fighters/bombers.) Maybe the player can land there to repair/reload?
- __Eyecatch__: A video or auto-playing level that appears on the title screen after a long-enough period of inactivity. Originally used in arcade machines to draw attention to a machine not currently being played.
- __Gallery/Library__: View detailed info on ships

## Mission Objectives

There are three categories for mission objectives: Primary, Secondary, and Secret.

- __Primary__: These are typically critical for mission success, and result in mission failure if even one is failed. If not marked as critical, it can be allowed to fail, maybe for story reasons.
- __Secondary__: These are non-critical objectives that will give the player an advantage of some kind in either the next mission or a future one, like an additional wing of ships, reduced enemy presence, etc.
- __Secret__: Unlike Primary and Secondary Objectives, Secret Objectives are not visible from the briefing menu, and only appear once special conditions are met during the mission. These can unlock ships/weapons early, as well as ship skins or alternate models maybe?

## Resources

Here I'll list all resources I'm using for various assets, such as sound effects and typefaces.

### Typefaces

- __Game Logo typeface__: Nulshock by Typodermic Fonts https://www.dafont.com/nulshock.font?l[]=10&l[]=1
- Open Dyslexic: https://gumroad.com/l/OpenDyslexic
- Inconsolata: https://www.1001fonts.com/inconsolata-font.html

## Style Guide

I've followed the official [GDScript style guide](https://docs.godotengine.org/en/3.1/getting_started/scripting/gdscript/gdscript_styleguide.html) for the most part, but it doesn't say anything about ordering member declarations, signals, enums, etc. I've come up with an ordering scheme that lines up with the Godot documentation. Each section is listed in order below; private properties and methods come before public ones, and every member of each section is ordered alphabetically. The only exception is that `_ready` comes first in the methods, just for convenience.

1. Enumerations
2. Properties
3. export Properties (properties assigned from the editor)
4. onready Properties (properties assigned on `_ready` using the `onready` flag)
5. local Properties
6. Methods
7. static Methods
8. Signals
9. script Constants (custom scripts get loaded in pascal case instead of capital snake like other constants)
10. Constants

## Version Rules

Software version numbers are often obscure, so I've taken some time to write up some rules I'll follow to make sense of the version numbers I apply to this game. I'll follow the familiar format for version numbers: three whole numbers, each separated by a period. In addition to the version number, I'll be using the terms "Alpha", "Beta", and "Release" to better indicate the state of the software.

### Alpha, Beta, Release

I've heard the terms "Alpha" and "Beta" used very loosely in discussion about game development. I've never gotten a good sense that those terms have any concrete meaning apart from a general sense of pre-release status. In light of this confusion, I've come up with my own distinct descriptions for each classification:

- __Alpha__ refers to pre-build versions of the software. These versions do not exist as compiled executables, and are typically lacking necessary features for the complete release. This stage of development is largely constructive: building the basic structures needed to make the core game work.
- __Beta__ refers to pre-release versions of the software. These versions exist as compiled executables, but are lacking Minimal Viable Product (MVP) features. This stage is based around experimentation and building more complex features.
- __Release__ refers to release versions of the software. Once released, the only version updates should be to fix bugs, make quality-of-life improvements, and add content.

### Version Numbers

Version numbers are more sensible, though initially confusing. The use of a period as separator can make the number look like a decimal, but this is not the case. I'll list the version numbers and what they mean for my project.

- __First Digit: Major Version__ - This refers to a significant, or *major*, update as the culmination of minor updates.
- __Second Digit: Minor Version__ - This refers to the addition of a feature or content.
- __Third Digit: Patch Version__ - This refers to adjustments and fixes to the current minor version.

A complete version number will begin with the development stage name, followed by the version numbers. E.G. A build in the Beta stage at major version 2, minor version 12, patch version 3 would look like this `Beta 2.12.3`
