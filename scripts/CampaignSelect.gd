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
