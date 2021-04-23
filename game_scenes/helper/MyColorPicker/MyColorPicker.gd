extends ColorPicker

func _ready():
	#
	# @@15 Color Picker Dropper
	#
	var cpicker1 = get_child(7)
	cpicker1.hide()
	#
	# @@68 Preset Button
	#
	var cpicker2 = get_child(1)
	cpicker2.hide()
	#
	# @@20/@@57/@@58 HSV Button
	#
	
	var cpicker3 = get_child(4)
	cpicker3.hide()
	#
	# @@20/@@57/@@59 RAW Button
	#
	var cpicker4 = get_child(3)
	cpicker4.hide()
