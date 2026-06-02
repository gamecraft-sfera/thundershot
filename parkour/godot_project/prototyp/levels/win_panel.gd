extends Panel

signal on_name_entered
var author_name: String

func _on_ok_button_pressed() -> void:
	if ($TextEdit.text as String).length() > 2:
		author_name = $TextEdit.text
		on_name_entered.emit()
