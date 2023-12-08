extends Node3D

@onready var editor_label: Label = %EditorLabel
@onready var player_labels: VBoxContainer = %PlayerLabels
@onready var moves_label: Label = %MovesLabel
@onready var player_controls: VBoxContainer = %PlayerControls
@onready var reload_scene_timer: Timer = $ReloadSceneTimer

var player: Node

var moves: int = -1
var score: int = 0
var targets: int = 0

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().change_scene_to_file("res://PackSelection.tscn")

func _on_cursor_play_mode_requested(validation_result: Levels.ValidationResult) -> void:
	if validation_result == Levels.ValidationResult.SUCCESS:
		editor_label.visible = false

		Progress.load_progress()

		var children: Array[Node] = get_children()
		for child in children:
			if child.get_meta("is_player", false):
				player = child
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

	if Progress.best_moves > 0:
		moves_label.text += " (Best: %d)" % Progress.best_moves

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
		player.is_playing = false

		if Levels.level + 1 == Levels.levels:
			Progress.save_progress(moves, true)
			player_labels.set_win_label()
		else:
			Progress.save_progress(moves)
			Levels.level += 1
			reload_scene_timer.start()
	else:
		player_labels.set_score_label(score, targets)

func _on_reload_scene_timer_timeout() -> void:
	get_tree().reload_current_scene()
