extends Control

onready var loader = get_node("/root/SceneLoader")
onready var mission_data = get_node("/root/MissionData")


func _ready():
	var default_campaign_rows = get_node("MarginContainer/Campaign Rows/Default Campaigns Panel/Default Campaigns Scroll/Default Campaign Rows")
	var custom_campaign_rows = get_node("MarginContainer/Campaign Rows/Custom Campaigns Panel/Custom Campaigns Scroll/Custom Campaign Rows")

	for campaign_data in mission_data.default_campaign_list:
		var campaign_button = Button.new()
		default_campaign_rows.add_child(campaign_button)

		campaign_button.set_text_align(Button.ALIGN_LEFT)
		campaign_button.set_text(campaign_data.name + ": " + campaign_data.description)
		campaign_button.connect("pressed", self, "_on_campaign_button_pressed", [ campaign_data.path ])


func _on_campaign_button_pressed(campaign_path: String):
	# Load campaign data and save campaign path to current profile
	mission_data.load_campaign_data(campaign_path, true)
	# Load first mission in campaign and save first mission path to current profile
	mission_data.load_mission_data(mission_data.campaign_data.missions[0].path, true)
	mission_data.is_in_campaign = true
	loader.load_scene("res://briefing.tscn")
