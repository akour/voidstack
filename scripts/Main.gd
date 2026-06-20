extends Node2D

@onready var ad_manager = $AdManager
@onready var score_label: Label = $UI/Root/TopBar/ScoreLabel
@onready var best_score_label: Label = $UI/Root/TopBar/BestScoreLabel
@onready var perfect_label: Label = $UI/Root/PerfectLabel
@onready var game_over_panel: PanelContainer = $UI/Root/GameOverPanel
@onready var continue_button: Button = $UI/Root/GameOverPanel/VBox/ContinueButton
@onready var restart_button: Button = $UI/Root/GameOverPanel/VBox/RestartButton

var score := 0
var best_score := 0
var perfect_combo := 0
var used_continue_this_run := false


func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	_update_score_ui()
	_hide_game_over()


func _update_score_ui() -> void:
	score_label.text = "Score: %d" % score
	best_score_label.text = "Best: %d" % best_score


func _show_perfect(combo: int) -> void:
	# Gameplay will call this when a block lands almost exactly aligned.
	perfect_label.text = "PERFECT!" if combo <= 1 else "PERFECT x%d" % combo
	perfect_label.visible = true


func _show_game_over() -> void:
	ad_manager.show_interstitial_if_needed()
	game_over_panel.visible = true
	continue_button.disabled = used_continue_this_run or not ad_manager.can_show_rewarded_continue()


func _hide_game_over() -> void:
	game_over_panel.visible = false
	perfect_label.visible = false


func _on_continue_pressed() -> void:
	if used_continue_this_run:
		return

	if ad_manager.show_rewarded_continue():
		used_continue_this_run = true
		_hide_game_over()
		# Later this will restore the falling block and continue from the same score.


func _on_restart_pressed() -> void:
	score = 0
	perfect_combo = 0
	used_continue_this_run = false
	_update_score_ui()
	_hide_game_over()
