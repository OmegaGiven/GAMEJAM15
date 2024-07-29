extends Node

var dialogue_opened = false
var skip_dialogue_typing = false
var TEXT_SPEED = 0.2


func _process(delta):
	if dialogue_opened:
		get_tree().paused

func TypeText(text, label):
	for character in text:
		label.text += character
		if !skip_dialogue_typing:
			await get_tree().create_timer(TEXT_SPEED).timeout


func CreateDialogue(text_chunk):
	var dialogue_box = CanvasLayer.new()
	var dialogue_label = RichTextLabel.new()
	dialogue_box.add_child(dialogue_label)
	dialogue_opened = true
	dialogue_label.anchors_preset = 5 #5: Center Top
	dialogue_label.size.x = Settings.resolution_x * 0.9
	dialogue_label.size.y = Settings.resolution_y * 0.2
	TypeText(text_chunk, dialogue_label)
	skip_dialogue_typing = false
	return dialogue_box
