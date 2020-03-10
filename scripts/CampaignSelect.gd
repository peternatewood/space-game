extends Control


func _ready():
	var default_campaign_rows = get_node("MarginContainer/Campaign Rows/Default Campaigns Panel/Default Campaigns Scroll/Default Campaign Rows")
	var custom_campaign_rows = get_node("MarginContainer/Campaign Rows/Custom Campaigns Panel/Custom Campaigns Scroll/Custom Campaign Rows")

	for campaign_data in MissionData.default_campaign_list:
		var campaign_button = Button.new()
		default_campaign_rows.add_child(campaign_button)

		campaign_button.set_text_align(Button.ALIGN_LEFT)
		campaign_button.set_text(campaign_data.name + ": " + campaign_data.description)
		campaign_button.connect("pressed", self, "_on_campaign_button_pressed", [ campaign_data.path ])

	if MissionData.custom_campaign_list.size() != 0:
		var custom_none_label = get_node("MarginContainer/Campaign Rows/Custom Campaigns Panel/Custom Campaigns Scroll/Custom Campaign Rows/None Label")
		custom_none_label.queue_free()

		for campaign_data in MissionData.custom_campaign_list:
			var campaign_button = Button.new()
			custom_campaign_rows.add_child(campaign_button)

			campaign_button.set_text_align(Button.ALIGN_LEFT)
			campaign_button.set_text(campaign_data.name + ": " + campaign_data.description)
			campaign_button.connect("pressed", self, "_on_campaign_button_pressed", [ campaign_data.path ])

	var back_button = get_node("MarginContainer/Campaign Rows/Back Button")
	back_button.connect("pressed", self, "_on_back_pressed")


func _on_back_pressed():
	SceneLoader.change_scene("res://title.tscn")


func _on_campaign_button_pressed(campaign_path: String):
	# Load campaign data and save campaign path to current profile
	MissionData.load_campaign_data(campaign_path, true)
	# Load first mission in campaign and save first mission path to current profile
	MissionData.load_mission_data(MissionData.campaign_data.missions[0].path, true)
	MissionData.is_in_campaign = true
	SceneLoader.change_scene("res://briefing.tscn")
