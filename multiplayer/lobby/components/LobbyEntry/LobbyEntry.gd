extends Button

signal selected(lobby)

var _lobby	

func set_lobby(lobby):
	_lobby = lobby
	text = lobby.name
#	$Name.text = lobby.name

func join(event):
	if event is InputEventMouseButton:
		emit_signal("selected", _lobby)
