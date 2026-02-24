extends Node

var player: Player
var result_panel: ResultTextPanel:
	set(value):
		result_panel = value
		result_panel.setup_final_text(final_text)
		
var next_level_portal: NextLevelPortal

var found_words: Array[String] = []
var required_words: Array[String] = []

var final_text: String = "":
	set(value):
		final_text = value
		found_words.clear()
		required_words = extract_required_words(final_text)
		print("Required words: ", required_words)
		if result_panel:
			result_panel.setup_final_text(final_text)

func _ready():
	pass

func extract_required_words(text: String) -> Array[String]:
	var words: Array[String] = []
	var regex = RegEx.new()
	regex.compile("\\[([^\\]]+)\\]")
	var results = regex.search_all(text)
	
	for result in results:
		words.append(result.get_string(1))
	
	return words

func word_found(word: String) -> void:
	if word in found_words:
		return  # Word already found
		
	found_words.append(word)
	print("Word found: ", word, " Total: ", found_words.size(), "/", required_words.size())
	
	if player:
		player.word_found(word)

func _on_puzzle_completed():
	print("Puzzle completed!")
	# Add any completion logic here
	# For example, show a success message, unlock next level, etc.

# For testing purposes - can be called manually
func force_show_result_panel():
	if player:
		show_result_panel()
		
func show_result_panel() -> void:
	player.result_text_panel.show_panel()
	
func hide_result_panel() -> void:
	player.result_text_panel.hide_panel()

func puzzle_succeeded() -> void:
	next_level_portal.visible = true
