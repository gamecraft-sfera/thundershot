extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		GameManager.show_result_panel()


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		GameManager.hide_result_panel()
