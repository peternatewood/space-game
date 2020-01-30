extends Control


func _ready():
	var close_button = get_node("VBoxContainer/HBoxContainer/Close Button")
	close_button.connect("pressed", self, "hide")

	# Build out the manual as TreeItems because this has to be done programmatically
	var tree = get_node("VBoxContainer/Tree")
	var tree_root = tree.create_item()
	tree.set_hide_root(true)

	for section in MANUAL_TEXT.keys():
		var section_item = tree.create_item(tree_root)
		section_item.set_text(0, section)
		section_item.set_collapsed(true)
		section_item.set_expand_right(0, false)

		for text in MANUAL_TEXT[section]:
			var child = tree.create_item(section_item)
			child.set_expand_right(0, false)

			if text is String:
				child.set_text(0, text)
			elif text is Dictionary:
				child.set_text(0, text.title)
				child.set_collapsed(true)

				for child_text in text.rows:
					var child_details = tree.create_item(child)
					child_details.set_text(0, child_text)
					child_details.set_expand_right(0, false)


const MANUAL_TEXT: Dictionary = {
	"Movement/Controls": [
		"Hold middle mouse to orbit",
		"Hold Shift and middle mouse to translate"
	],
	"File Menu": [
		"New: Create a new mission",
		"Open: Open a mission from file",
		"Save: Save a mission to file",
		"Quit to Menu: Quit to the Title screen",
		"Quit to Desktop: Quit to the Desktop"
	],
	"Edit Menu": [
		"Add Ship: Open the Add Ship dialog",
		"Edit Ship: Open the Edit Ship panel",
		"Add Waypoint: Open the Add Waypoint dialog",
		"Edit Waypoint: Open the Edit Waypoint panel"
	],
	"Mission": [
		"Details: Open the Mission Details dialog",
		"Wings: Open the Wings dialog",
		"Waypoint Groups: Open the Waypoint Groups dialog",
		"Objectives: Open the Objectives panel",
		"Armory: Open the Armory dialog",
		"Factions: Open the Factions dialog"
	],
	"Help": [
		"About: Shows the current version number of the editor, and by extension the game",
		"Manual: Shows this very manual you are reading!"
	],
	"Add Ship": [
		"Name: choose a unique name for the new ship",
		"Ship Class: choose the ship's class from the list",
		{
			"title": "Defaults: When the ship is added, its other properties will have the following defaults",
			"rows": [
				"Position: x: 0, y: 0, z: 0",
				"Rotation: x: 0, y: 0, z: 0",
				"Player Ship: false; it will be an NPC Ship",
				"Faction: none",
				"Hitpoints: the default maximum hitpoints for the chosen Ship Class",
				"Weapons: the default weapons loadout for the chosen Ship Class",
				"Warped In: true",
				"Ship Orders: all Passive"
			]
		}
	],
	"Edit Ship": [
		"Position and rotation are updated immediately",
		"Must press Update button for any other changes",
		"Press the Delete button to remove this ship.",
		{
			"title": "Position: Ship's position in Godot Units.",
			"rows": [
				"One Godot Unit equals 10 meters (3.28084 ft).",
				"Negative X is left, Positive X is right.",
				"Negative Y is down, Positive Y is up.",
				"Negative Z is forward, Positive Z is backward. In Godot, the Z directional axis is reversed from most other 3D editing software."
			]
		},
		"Rotation: ship's rotation in degrees. X corresponds to Pitch, Y to Yaw, and Z to Roll.",
		{
			"title": "Player Ship: whether this ship is the player-controlled ship.",
			"rows": [
				"Only one ship can be player-controlled at once, so if this is toggled on,",
				"  any other ship already designated as player-controlled will be turned into an NPC Ship."
			]
		},
		"Ship Class: the class of ship.",
		{
			"title": "Faction: Faction name this ship is a part of.",
			"rows": [
				"If a ship has the Attack Any order, it will only target ships it recognizes as Hostile via its alignment to their factions.",
				"See the Factions menu for more info on Alignments"
			]
		},
		"Hitpoints: starting hitpoints for this ship. Set to -1 to use the ship class's maximum hitpoints.",
		"Name: unique name for the ship",
		"Wing Name: Player-controlled wing to which this ship belongs",
		"Weapon Slots: equipped weapon in a given slot. For Capital Ships, these correspond to weapons turrets.",
		{
			"title": "Warped In: whether the ship begins the mission warped in.",
			"rows": [
				"This option is not available for the Player's ship"
			]
		},
		"Ship Orders: Starting orders for the ship. These options are not available for the Player's ship."
	],
	"Waypoints": [
		{
			"title": "Waypoint Groups Dialog",
			"rows": [
				"Provide named groups for waypoints",
				"A group name is used by NPC Ships for patrolling, and will follow the waypoints in the order they appear in the editing panel",
				"Click OK to set the group names",
				"Click Add Group to add another text field and enter a new name"
			]
		},
		{
			"title": "Add Waypoints Dialog",
			"rows": [
				"Must have at least one Waypoint Group set (provide default one?)",
				"Choose group from the list"
			]
		},
		{
			"title": "Edit Waypoints Panel",
			"rows": [
				"Position is updated immediately",
				"Deleting a waypoint will update the every other waypoint's name"
			]
		}
	],
	"Add Objectives Panel": [
		"Adding an objective creates an empty object with no name",
		"Edit the objective to fill out it's details"
	],
	"Edit Objectives Dialog": [
		"You must press the OK button to save all changes made in this panel",
		"Name: the name of the objective, as it appears in the Briefing menu and player HUD",
		{
			"title": "Enabled: whether the objective is Enabled at the start of the mission.",
			"rows": [
				"Enabled objectives will appear on the Briefing menu and the HUD.",
				"If an objective not Enabled, use Trigger Requirements to decide under what conditions the objective is enabled.",
				"Note: Secret Objectives will always be disabled at the start of a mission."
			]
		},
		{
			"title": "Critical: Whether this objective is required for the mission to succeed.",
			"rows": [
				"All critical objectives must be met for mission success.",
				"If a critical objective fails, the mission fails."
			]
		},
		{
			"title": "Requirements: Objective requirements that trigger success or failure.",
			"rows": [
				"Success requirements must all be met in order for the objective to succeed.",
				"If just one failure requirement is met, and the objective has not already succeeded, the objective will fail.",
				"Trigger requirements will enable the objective if it's not Enabled at the mission start. All trigger requirements must be met for this.",
				"Type:",
				"- Patrol: *this requirement type is currently non-functional*",
				"- Destroy: this requirement will succeed when all provided ships are destroyed",
				"- Defend: this requirement will trigger its objective to fail when all provided ships are destroyed",
				"- Objective: this requirement will succeed when the given objective succeeds or fail when the given objective fails",
				"- Ships Arrive: this requirement will succeed when all provided ships have completed warping in",
				"- Ships Leave: this requirement will succeed when all provided ships have completed warping out",
				"Waypoints: (only for Patrol type requirements) *this feature is currently non-functional*",
				"Objective Type: (only for Objective type requirements) designates that the given objective is of the Primary, Secondary, or Secret type",
				"Objective: (only for Objective type requirements) the objective that triggers this requirement",
				"Targets:",
				"- Press the Add Target button to add a Target object to the list, which will default to the first ship in the scene",
				"- Choose a ship from the list",
				"- Press the Delete button to remove the target from the list",
				"Press the Delete Requirement button to remove this requirement from the list"
			]
		}
	],
	"Wings: Edit the list of player-controlled Wings for the mission.": [
		"Each wing must have 1-4 ships, and will appear in the Loadout menu for the player to equip before the mission.",
		"The Reinforcements checkbox designates a wing as reinforcements: adding them to the Reinforcements section of the Communications menu,",
		"  and setting all ships in that wing to be not yet warped in at the start of the mission",
		"Leave a wing name blank to exclude it from the list",
		"There are a maximum of 6 wings available",
		"Alpha wing is provided by default"
	],
	"Factions: Factions are used to determine alignment between different ships": [
		"You must press the OK button for changes to take effect",
		"Click the Add Faction button to add an empty Faction object",
		"Editing factions:",
		"- Name: the name of the faction; strictly for editor use, this name will not appear in the mission anywhere",
		"- Alignments: for each faction, an alignment option for the other factions will be provided.",
		"  Choose whether the faction recognizes each other as Neutral, Friendly, or Hostile.",
		"- Press the Delete Button to remove this Faction from the list"
	],
	"Armory: Ships and weapons available to the player in the loadout menu": [
		"You must press the OK button for changes to take effect",
		"Ships",
		"Energy Weapons",
		"Missile Weapons"
	],
	"Mission Details: Dialog for certain mission details": [
		"Name: mission name as it will appear in the Mission Select and at the top of the Briefing menu.",
		"Briefing: simple text briefing that will appear in the Briefing menu. *This feature will be more fleshed out in future updates*"
	]
}
