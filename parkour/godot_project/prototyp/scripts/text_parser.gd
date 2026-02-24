extends RefCounted
class_name TextParser

# Parses text with [word] patterns and returns structured data for UI creation
# Example: "Hello [world]!" returns:
# [
#   {"type": "label", "text": "Hello "},
#   {"type": "drop_zone", "expected_word": "world", "placed_word": null},
#   {"type": "label", "text": "!"}
# ]
static func parse_final_text(text: String) -> Array:
	var result: Array = []
	var current_pos: int = 0
	
	while current_pos < text.length():
		var bracket_start = text.find("[", current_pos)
		
		if bracket_start == -1:
			# No more brackets, add remaining text as label
			if current_pos < text.length():
				var remaining_text = text.substr(current_pos)
				if remaining_text.strip_edges() != "":
					result.append({
						"type": "label",
						"text": remaining_text
					})
			break
		
		# Add text before bracket as label (if not empty)
		if bracket_start > current_pos:
			var before_text = text.substr(current_pos, bracket_start - current_pos)
			if before_text.strip_edges() != "":
				result.append({
					"type": "label", 
					"text": before_text
				})
		
		# Find closing bracket
		var bracket_end = text.find("]", bracket_start)
		if bracket_end == -1:
			# Malformed text, treat rest as label
			var remaining_text = text.substr(bracket_start)
			if remaining_text.strip_edges() != "":
				result.append({
					"type": "label",
					"text": remaining_text
				})
			break
		
		# Extract word from brackets
		var word = text.substr(bracket_start + 1, bracket_end - bracket_start - 1)
		result.append({
			"type": "drop_zone",
			"expected_word": word,
			"placed_word": null
		})
		
		current_pos = bracket_end + 1
	
	return result
