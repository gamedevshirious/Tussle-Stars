extends Control

func show_notification(msg):
	$Message.text = msg
	$Tween.interpolate_property(self, "rect_position", Vector2(90, -90), Vector2(90, 0), 1,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
		
	$Tween.start()

func _on_Tween_tween_all_completed():
	$Timer.start()

func _on_Timer_timeout():
	queue_free()
