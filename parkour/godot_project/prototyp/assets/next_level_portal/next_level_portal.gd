class_name NextLevelPortal extends Area3D

@export var next_level: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.next_level_portal = self
	


func _on_body_entered(body: Node3D) -> void:
	if visible and body.is_in_group("player"):
		switch_to_next_scene()

func switch_to_next_scene() -> void:
	if next_level == null:
		print("Warning: No next level scene assigned to portal")
		return
	
	# Get the current scene
	var current_scene = get_tree().current_scene
	
	# Load and instantiate the next level
	var next_scene_instance = next_level.instantiate()
	
	# Add the new scene to the scene tree
	get_tree().root.add_child(next_scene_instance)
	
	# Set it as the current scene
	get_tree().current_scene = next_scene_instance
	
	# Free the current scene
	current_scene.queue_free()
