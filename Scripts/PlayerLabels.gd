extends VBoxContainer

@onready var player_level_label: Label = $PlayerLevelLabel
@onready var score_label: Label = $ScoreLabel

func update_level_label() -> void:
	player_level_label.text = "Level: %d" % (Levels.level + 1)

func set_score_label(score: int, targets: int) -> void:
	score_label.text = "Score: %d/%d" % [score, targets]

func set_win_label() -> void:
	score_label.text = "You win!"
