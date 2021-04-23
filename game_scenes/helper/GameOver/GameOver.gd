extends Popup

func _on_ReturnToHomeButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://game_scenes/MainMenu.tscn")
