extends Node


var dialogue_opened = false
var skip_dialogue_typing = false
var TEXT_SPEED = 0.2


func TypeText(text, label):
	for character in text:
		label.text += character
		await get_tree().create_timer(TEXT_SPEED).timeout


func CreateDialogue(text_chunk):
	var dialogue_box = CanvasLayer.new()
	var dialogue_label = RichTextLabel.new()
	dialogue_label.anchors_preset = 5 #5: Center Top
	dialogue_label.size.x = Settings.resolution_x * 0.9
	dialogue_label.size.y = Settings.resolution_y * 0.2
	TypeText(text_chunk, dialogue_label)
	return dialogue_box
