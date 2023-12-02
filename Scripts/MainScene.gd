extends Node3D

@onready var editor_label: Label = %EditorLabel
@onready var player_labels: VBoxContainer = %PlayerLabels
@onready var moves_label: Label = %MovesLabel
@onready var player_controls: VBoxContainer = %PlayerControls

var player: Node
var best_moves: int

var moves: int = -1
var score: int = 0
var targets: int = 0

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().change_scene_to_file("res://PackSelection.tscn")

func _on_cursor_play_mode_requested(validation_result: Levels.ValidationResult) -> void:
	if validation_result == Levels.ValidationResult.SUCCESS:
		editor_label.visible = false

		var children: Array[Node] = get_children()
		for child in children:
			if child.get_meta("is_player", false):
				player = child
				best_moves = Moves.read_level_moves()
				player_moved(0.0, 0.0)
				child.connect("moved", player_moved)
				player.is_playing = true
			elif child.get_meta("is_box", false):
				child.prepare()
			elif child.get_meta("is_target", false):
				targets += 1
				child.connect("entered", target_entered)
				child.connect("exited", target_exited)
				child.is_playing = true

		player_labels.update_level_label()
		player_labels.set_score_label(0, targets)
		player_labels.visible = true
		player_controls.visible = true

func player_moved(_x: float, _y: float) -> void:
	moves += 1
	moves_label.text = "Moves: %d" % moves

	if best_moves > 0:
		moves_label.text += " (Best: %d)" % best_moves

func target_entered() -> void:
	score += 1
	check_score()

func target_exited() -> void:
	score -= 1
	check_score()

func check_score() -> void:
	if score < 0:
		score = 0
	elif score == targets:
		if best_moves == 0 or moves < best_moves:
			Moves.save_level_moves(moves)

		if Levels.level + 1 == Levels.levels:
			player.is_playing = false
			player_labels.set_win_label()
		else:
			Levels.next_level()
			get_tree().reload_current_scene()
	else:
		player_labels.set_score_label(score, targets)
