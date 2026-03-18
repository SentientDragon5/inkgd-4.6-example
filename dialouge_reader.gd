extends Control

@export var ink_file: InkResource
@export var display_label: RichTextLabel
@export var button_container: VBoxContainer

var story: InkStory

func _ready():
	if ink_file:
		_setup_story()

func _setup_story():
	story = InkStory.new(ink_file.json)
	story.bind_external_function("should_show_debug_menu", self, "_should_show_debug_menu")
	_continue_story()

func _should_show_debug_menu(_arg):
	return false

func _continue_story():
	_clear_buttons()
	
	var text = story.continue_story_maximally()
	
	if text:
		# Use BBCode to keep the current text white/default
		display_label.append_text(text + "\n")
	
	if story.current_choices.size() > 0:
		_display_choices()
	else:
		display_label.append_text("\n[center][i]--- End of Story ---[/i][/center]")

func _display_choices():
	for i in range(story.current_choices.size()):
		var choice = story.current_choices[i]
		var btn = Button.new()
		btn.text = choice.text
		btn.pressed.connect(_on_choice_selected.bind(i))
		button_container.add_child(btn)

func _on_choice_selected(index: int):
	# 1. Get the current full text
	var full_content = display_label.get_parsed_text()
	
	# 2. Clear the label and re-add everything wrapped in a grey color tag
	display_label.clear()
	display_label.append_text("[color=#888888]" + full_content + "[/color]")
	
	# 3. Add the player's choice in a different color to show the history branch
	var choice_text = story.current_choices[index].text
	display_label.append_text("\n[color=#aaaaaa]> " + choice_text + "[/color]\n\n")
	
	story.choose_choice_index(index)
	_continue_story()

func _clear_buttons():
	for child in button_container.get_children():
		child.queue_free()
