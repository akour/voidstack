extends Node2D

const BLOCK_SCENE := preload("res://Block.tscn")
const SAVE_PATH := "user://save.cfg"

const VIEWPORT_SIZE := Vector2(720.0, 1280.0)
const START_BLOCK_SIZE := Vector2(300.0, 54.0)
const BASE_Y := 980.0
const DROP_HEIGHT := 190.0
const MOVE_SPEED := 235.0
const SPEED_STEP := 18.0
const MAX_SPEED_BONUS := 45.0
const MIN_BLOCK_WIDTH := 18.0
const PERFECT_THRESHOLD := 12.0
const RELAX_MOVE_SPEED := 120.0
const RELAX_MAX_SPEED_BONUS := 8.0
const RELAX_PERFECT_THRESHOLD := 26.0
const RELAX_MIN_BLOCK_WIDTH := 8.0
const CAMERA_ZOOM := Vector2(1.35, 1.35)
const CAMERA_FOLLOW_OFFSET := 285.0
const SAFE_TOP_MARGIN := 84.0
const PLUTO_HEIGHT := 125.0
const MODE_MISSION := "mission"
const MODE_RELAX := "relax"
const PERFECT_EXACT_THRESHOLD := 2.0
const RELAX_PERFECT_EXACT_THRESHOLD := 3.0
const KM_PER_LIGHT_YEAR := 9460730472580.8

const SFX_VOLUME_DB := {
	"drop": -10.0,
	"land": -3.0,
	"perfect": -12.0,
	"combo": -9.0,
	"game_over": -7.0,
	"button": -14.0,
}

const THEMES := [
	{
		"id": "earth_orbit",
		"name": "Earth Orbit",
		"unlock": 0,
		"top": Color(0.015, 0.025, 0.09),
		"bottom": Color(0.06, 0.02, 0.16),
		"blocks": [Color(0.1, 0.92, 1.0), Color(0.72, 0.38, 1.0), Color(1.0, 0.28, 0.78)],
		"particle": Color(0.38, 0.95, 1.0),
	},
	{
		"id": "mars_dust",
		"name": "Mars Dust",
		"unlock": 15,
		"top": Color(0.08, 0.025, 0.035),
		"bottom": Color(0.18, 0.055, 0.02),
		"blocks": [Color(1.0, 0.31, 0.52), Color(1.0, 0.62, 0.18), Color(0.75, 0.23, 1.0)],
		"particle": Color(1.0, 0.46, 0.28),
	},
	{
		"id": "europa_ice",
		"name": "Europa Ice",
		"unlock": 35,
		"top": Color(0.015, 0.045, 0.12),
		"bottom": Color(0.025, 0.11, 0.17),
		"blocks": [Color(0.44, 1.0, 1.0), Color(0.62, 0.72, 1.0), Color(0.94, 0.42, 1.0)],
		"particle": Color(0.74, 1.0, 1.0),
	},
	{
		"id": "titan_fog",
		"name": "Titan Fog",
		"unlock": 60,
		"top": Color(0.045, 0.03, 0.08),
		"bottom": Color(0.13, 0.09, 0.035),
		"blocks": [Color(0.95, 0.54, 1.0), Color(0.25, 0.95, 1.0), Color(1.0, 0.74, 0.3)],
		"particle": Color(0.95, 0.72, 1.0),
	},
	{
		"id": "the_void",
		"name": "The Void",
		"unlock": 100,
		"top": Color(0.0, 0.0, 0.025),
		"bottom": Color(0.025, 0.0, 0.055),
		"blocks": [Color(0.0, 1.0, 0.95), Color(1.0, 0.12, 0.9), Color(0.55, 0.18, 1.0)],
		"particle": Color(1.0, 0.16, 0.92),
	},
]

const JOURNEY_STOPS := [
	{"height": 0, "id": "earth", "icon": "🌍", "name": "EARTH", "distance": 0.0},
	{"height": 10, "id": "moon", "icon": "🌕", "name": "MOON", "distance": 384400.0},
	{"height": 25, "id": "mars", "icon": "🔴", "name": "MARS", "distance": 225000000.0},
	{"height": 45, "id": "jupiter", "icon": "🟠", "name": "JUPITER", "distance": 778000000.0},
	{"height": 65, "id": "saturn", "icon": "🪐", "name": "SATURN", "distance": 1430000000.0},
	{"height": 85, "id": "uranus", "icon": "🧊", "name": "URANUS", "distance": 2870000000.0},
	{"height": 105, "id": "neptune", "icon": "🔵", "name": "NEPTUNE", "distance": 4500000000.0},
	{"height": 125, "id": "pluto", "icon": "❄️", "name": "PLUTO", "distance": 5900000000.0},
	{"height": 150, "id": "oort_cloud", "icon": "☄️", "name": "OORT CLOUD", "distance": 7500000000000.0},
	{"height": 175, "id": "alpha_centauri", "icon": "✨", "name": "ALPHA CENTAURI", "distance": KM_PER_LIGHT_YEAR * 4.37},
	{"height": 200, "id": "proxima_b", "icon": "🟢", "name": "PROXIMA B", "distance": KM_PER_LIGHT_YEAR * 4.45},
	{"height": 230, "id": "trappist_worlds", "icon": "🌐", "name": "TRAPPIST SYSTEM", "distance": KM_PER_LIGHT_YEAR * 40.7},
	{"height": 260, "id": "interstellar_space", "icon": "🚀", "name": "INTERSTELLAR SPACE", "distance": KM_PER_LIGHT_YEAR * 100.0},
	{"height": 300, "id": "orion_arm", "icon": "🌠", "name": "ORION ARM", "distance": KM_PER_LIGHT_YEAR * 10000.0},
	{"height": 350, "id": "milky_way", "icon": "🌌", "name": "MILKY WAY", "distance": KM_PER_LIGHT_YEAR * 100000.0},
	{"height": 425, "id": "andromeda", "icon": "🔭", "name": "ANDROMEDA", "distance": KM_PER_LIGHT_YEAR * 2500000.0},
	{"height": 500, "id": "deep_void", "icon": "🕳", "name": "DEEP VOID", "distance": KM_PER_LIGHT_YEAR * 10000000.0},
	{"height": 600, "id": "infinity", "icon": "♾️", "name": "INFINITY", "distance": KM_PER_LIGHT_YEAR * 100000000.0},
]

const DEEP_SPACE_DISCOVERIES := [
	{"icon": "✨", "name": "ANCIENT NEBULA"},
	{"icon": "🌌", "name": "GALAXY CROSSING"},
	{"icon": "☄️", "name": "COSMIC STORM"},
	{"icon": "🕳", "name": "BLACK HOLE APPROACH"},
	{"icon": "👽", "name": "UNKNOWN SIGNAL"},
	{"icon": "💫", "name": "QUASAR LIGHT"},
	{"icon": "🔭", "name": "LOST OBSERVATORY"},
	{"icon": "🧊", "name": "FROZEN COMET FIELD"},
	{"icon": "🌠", "name": "STARFALL DRIFT"},
	{"icon": "🌀", "name": "GRAVITY WELL"},
]

@onready var gradient_top: ColorRect = $Background/GradientTop
@onready var gradient_bottom: ColorRect = $Background/GradientBottom
@onready var space_window_tint: ColorRect = $Background/SpaceWindowTint
@onready var distant_body: Panel = $Background/DistantBody
@onready var distant_ring: ColorRect = $Background/DistantRing
@onready var horizon_line: ColorRect = $Background/HorizonLine
@onready var float_particles: Node2D = $FloatParticles
@onready var game_layer: Node2D = $GameLayer
@onready var effects_layer: Node2D = $EffectsLayer
@onready var camera: Camera2D = $Camera2D
@onready var ad_manager = $AdManager
@onready var button_sfx: AudioStreamPlayer = $Audio/ButtonSFX
@onready var game_over_sfx: AudioStreamPlayer = $Audio/GameOverSFX
@onready var land_sfx: AudioStreamPlayer = $Audio/LandSFX
@onready var perfect_sfx: AudioStreamPlayer = $Audio/PerfectSFX
@onready var music_player: AudioStreamPlayer = $Audio/MusicPlayer
@onready var title_screen: Control = $UI/Root/TitleScreen
@onready var title_best_label: Label = $UI/Root/TitleScreen/TitleVBox/TitleBestLabel
@onready var play_button: Button = $UI/Root/TitleScreen/TitleVBox/PlayButton
@onready var relax_button: Button = $UI/Root/TitleScreen/TitleVBox/RelaxButton
@onready var themes_button: Button = $UI/Root/TitleScreen/TitleVBox/ThemesButton
@onready var settings_button: Button = $UI/Root/TitleScreen/TitleVBox/SettingsButton
@onready var mode_label: Label = $UI/Root/TitleScreen/TitleVBox/ModeLabel
@onready var mode_subtitle_label: Label = $UI/Root/TitleScreen/TitleVBox/ModeSubtitleLabel
@onready var theme_menu: PanelContainer = $UI/Root/ThemeMenu
@onready var map_start_button: Button = $UI/Root/ThemeMenu/ThemeVBox/MapModeToggle/MapStartButton
@onready var map_relax_button: Button = $UI/Root/ThemeMenu/ThemeVBox/MapModeToggle/MapRelaxButton
@onready var map_scroll: ScrollContainer = $UI/Root/ThemeMenu/ThemeVBox/MapScroll
@onready var theme_list: Control = $UI/Root/ThemeMenu/ThemeVBox/MapScroll/ThemeList
@onready var map_info_label: Label = $UI/Root/ThemeMenu/ThemeVBox/MapInfoLabel
@onready var theme_back_button: Button = $UI/Root/ThemeMenu/ThemeVBox/ThemeBackButton
@onready var settings_panel: PanelContainer = $UI/Root/SettingsPanel
@onready var sound_toggle_button: Button = $UI/Root/SettingsPanel/SettingsVBox/SoundToggleButton
@onready var music_toggle_button: Button = $UI/Root/SettingsPanel/SettingsVBox/MusicToggleButton
@onready var vibration_toggle_button: Button = $UI/Root/SettingsPanel/SettingsVBox/VibrationToggleButton
@onready var remove_ads_button: Button = $UI/Root/SettingsPanel/SettingsVBox/RemoveAdsButton
@onready var settings_back_button: Button = $UI/Root/SettingsPanel/SettingsVBox/SettingsBackButton
@onready var top_bar: VBoxContainer = $UI/Root/TopBar
@onready var journey_icon_label: Label = $UI/Root/TopBar/JourneyIconLabel
@onready var journey_name_label: Label = $UI/Root/TopBar/JourneyNameLabel
@onready var journey_subtitle_label: Label = $UI/Root/TopBar/JourneySubtitleLabel
@onready var score_label: Label = $UI/Root/TopBar/ScoreLabel
@onready var best_score_label: Label = $UI/Root/TopBar/BestScoreLabel
@onready var journey_checkpoint_label: Label = $UI/Root/TopBar/JourneyCheckpointLabel
@onready var pause_button: Button = $UI/Root/PauseButton
@onready var perfect_label: Label = $UI/Root/PerfectLabel
@onready var flash: ColorRect = $UI/Root/Flash
@onready var world_unlock_popup: PanelContainer = $UI/Root/WorldUnlockPopup
@onready var unlock_title_label: Label = $UI/Root/WorldUnlockPopup/UnlockVBox/UnlockTitleLabel
@onready var unlock_world_label: Label = $UI/Root/WorldUnlockPopup/UnlockVBox/UnlockWorldLabel
@onready var pause_menu: PanelContainer = $UI/Root/PauseMenu
@onready var resume_button: Button = $UI/Root/PauseMenu/PauseVBox/ResumeButton
@onready var pause_restart_button: Button = $UI/Root/PauseMenu/PauseVBox/PauseRestartButton
@onready var pause_main_menu_button: Button = $UI/Root/PauseMenu/PauseVBox/PauseMainMenuButton
@onready var pause_settings_button: Button = $UI/Root/PauseMenu/PauseVBox/PauseSettingsButton
@onready var game_over_panel: PanelContainer = $UI/Root/GameOverPanel
@onready var final_score_label: RichTextLabel = $UI/Root/GameOverPanel/VBox/FinalScoreLabel
@onready var continue_button: Button = $UI/Root/GameOverPanel/VBox/ContinueButton
@onready var continue_helper_label: Label = $UI/Root/GameOverPanel/VBox/ContinueHelperLabel
@onready var restart_button: Button = $UI/Root/GameOverPanel/VBox/RestartButton
@onready var game_over_main_menu_button: Button = $UI/Root/GameOverPanel/VBox/GameOverMainMenuButton
@onready var test_ad_overlay: Control = $UI/Root/TestAdOverlay
@onready var test_ad_title_label: Label = $UI/Root/TestAdOverlay/Panel/VBox/TestAdTitleLabel
@onready var test_ad_close_button: Button = $UI/Root/TestAdOverlay/Panel/VBox/TestAdCloseButton
@onready var test_ad_complete_button: Button = $UI/Root/TestAdOverlay/Panel/VBox/TestAdCompleteButton
@onready var test_ad_fail_button: Button = $UI/Root/TestAdOverlay/Panel/VBox/TestAdFailButton

var score := 0
var best_score := 0
var best_height_blocks := 0
var best_destination_height := 0
var best_perfect_streak := 0
var best_relax_height_blocks := 0
var best_relax_destination_height := 0
var placements := 0
var perfect_combo := 0
var last_feedback_tier := ""
var current_feedback_streak := 0
var max_continues := 3
var continues_used := 0
var blocks_at_continue := 0
var time_at_continue_ms := 0
var waiting_for_reward := false
var rewarded_ad_was_shown := false

var active_block
var top_block
var current_width := START_BLOCK_SIZE.x
var move_direction := 1.0
var move_speed := MOVE_SPEED
var color_index := 0
var playing := false
var paused := false
var dropping := false
var camera_target_y := 640.0
var floating_dots: Array[Dictionary] = []
var selected_theme_id := "earth_orbit"
var active_world_id := "earth_orbit"
var active_journey_id := "earth"
var last_discovery_index := -1
var target_distance_km := 0.0
var displayed_distance_km := 0.0
var dashboard_message_locked := false
var selected_mode_id := MODE_MISSION
var current_mode_id := MODE_MISSION
var map_mode_id := MODE_MISSION
var selected_map_entry_id := ""
var last_map_focus_sound_ms := 0
var map_last_scroll_index := -1
var map_touch_scrolling := false
var map_touch_moved := false
var map_touch_start := Vector2.ZERO
var map_touch_last := Vector2.ZERO
var map_scroll_velocity := 0.0
var unlocked_theme_ids := ["earth_orbit"]
var current_theme: Dictionary = {}
var on_title_screen := true
var sound_enabled := true
var music_enabled := true
var vibration_enabled := true
var ads_removed := false
var pending_test_ad_kind := ""
var settings_return_to_pause := false
var sfx_players: Dictionary = {}
var perfect_feedback_tween: Tween
var perfect_feedback_node: Label


func _ready() -> void:
	randomize()
	play_button.pressed.connect(_on_play_pressed)
	relax_button.pressed.connect(_on_relax_pressed)
	themes_button.pressed.connect(_show_theme_menu)
	settings_button.pressed.connect(_show_settings)
	map_start_button.pressed.connect(func() -> void: _set_map_mode(MODE_MISSION))
	map_relax_button.pressed.connect(func() -> void: _set_map_mode(MODE_RELAX))
	map_scroll.gui_input.connect(_handle_map_scroll_input)
	theme_back_button.pressed.connect(_on_back_to_title_pressed)
	settings_back_button.pressed.connect(_on_settings_back_pressed)
	pause_button.pressed.connect(_show_pause_menu)
	resume_button.pressed.connect(_resume_game)
	pause_restart_button.pressed.connect(_on_pause_restart_pressed)
	pause_main_menu_button.pressed.connect(_go_to_main_menu)
	pause_settings_button.pressed.connect(_show_settings)
	sound_toggle_button.pressed.connect(_toggle_sound)
	music_toggle_button.pressed.connect(_toggle_music)
	vibration_toggle_button.pressed.connect(_toggle_vibration)
	continue_button.gui_input.connect(_on_continue_gui_input)
	continue_button.pressed.connect(_on_continue_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	game_over_main_menu_button.pressed.connect(_go_to_main_menu)
	test_ad_close_button.pressed.connect(_on_test_interstitial_closed)
	test_ad_complete_button.pressed.connect(_on_test_reward_completed)
	test_ad_fail_button.pressed.connect(_on_test_reward_failed)
	if ad_manager.has_signal("rewarded_continue_completed"):
		ad_manager.rewarded_continue_completed.connect(_on_rewarded_continue_completed)
	if ad_manager.has_signal("rewarded_continue_failed"):
		ad_manager.rewarded_continue_failed.connect(_on_rewarded_continue_failed)
	if ad_manager.has_signal("rewarded_ad_shown"):
		ad_manager.rewarded_ad_shown.connect(_on_rewarded_ad_shown)
	if ad_manager.has_signal("rewarded_ad_state_changed"):
		ad_manager.rewarded_ad_state_changed.connect(_on_rewarded_ad_state_changed)
	_style_panels()
	_setup_audio()
	_setup_floating_particles()
	_load_best_score()
	_update_ad_settings()
	_unlock_worlds_for_height(false)
	_apply_selected_theme()
	_rebuild_theme_buttons()
	_update_settings_buttons()
	_update_mode_ui()
	_update_music_state()
	_clear_blocks()
	_show_title_screen()


func _exit_tree() -> void:
	for player in sfx_players.values():
		if player:
			player.stop()
	if music_player:
		music_player.stop()


func _process(delta: float) -> void:
	if playing and not paused and not dropping and active_block:
		_move_active_block(delta)

	camera.position.y = lerp(camera.position.y, camera_target_y, 8.0 * delta)
	_update_distance_counter(delta)
	_update_floating_particles(delta)
	_update_map_touch_inertia(delta)
	_update_map_scroll_focus_feedback()


func _input(event: InputEvent) -> void:
	_try_drop_from_input(event)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _handle_back_requested():
		get_viewport().set_input_as_handled()
		return

	_try_drop_from_input(event)


func _handle_back_requested() -> bool:
	if settings_panel.visible:
		_on_settings_back_pressed()
		return true
	if theme_menu.visible:
		_on_back_to_title_pressed()
		return true
	if pause_menu.visible:
		_resume_game()
		return true
	if game_over_panel.visible:
		_go_to_main_menu()
		return true
	if playing and not paused:
		_show_pause_menu()
		return true
	if on_title_screen:
		_save_best_score()
		get_tree().quit()
		return true
	return false


func _try_drop_from_input(event: InputEvent) -> void:
	if on_title_screen or paused or not playing or dropping or game_over_panel.visible:
		return

	if event is InputEventScreenTouch and event.pressed:
		_drop_active_block()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_drop_active_block()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		_drop_active_block()


func _start_new_run() -> void:
	_clear_blocks()
	on_title_screen = false
	paused = false
	current_mode_id = selected_mode_id
	title_screen.visible = false
	theme_menu.visible = false
	settings_panel.visible = false
	pause_menu.visible = false
	top_bar.visible = true
	pause_button.visible = true
	top_bar.offset_top = 150.0
	top_bar.offset_bottom = 452.0
	pause_button.offset_top = SAFE_TOP_MARGIN + 2.0
	pause_button.offset_bottom = SAFE_TOP_MARGIN + 60.0
	score = 0
	placements = 0
	perfect_combo = 0
	last_feedback_tier = ""
	current_feedback_streak = 0
	continues_used = 0
	blocks_at_continue = 0
	time_at_continue_ms = 0
	current_width = START_BLOCK_SIZE.x
	move_speed = _current_move_speed()
	color_index = 0
	move_direction = 1.0
	active_world_id = "earth_orbit"
	active_journey_id = "earth"
	last_discovery_index = -1
	target_distance_km = 0.0
	displayed_distance_km = 0.0
	dashboard_message_locked = false
	_update_mode_ui()
	_apply_theme_by_id(active_world_id)
	_update_journey_display(_journey_stop_for_height(placements))
	camera.position = Vector2(VIEWPORT_SIZE.x * 0.5, VIEWPORT_SIZE.y * 0.5)
	camera.zoom = CAMERA_ZOOM
	camera_target_y = camera.position.y
	_hide_game_over()
	_update_score_ui()

	top_block = _create_block(Vector2(VIEWPORT_SIZE.x * 0.5, BASE_Y), START_BLOCK_SIZE)
	top_block.set_block_color(_block_color(color_index))
	_add_block_glow(top_block)
	_spawn_next_block()
	playing = true
	dropping = false


func _clear_blocks() -> void:
	for child in game_layer.get_children():
		child.queue_free()
	for child in effects_layer.get_children():
		child.queue_free()


func _create_block(pos: Vector2, size: Vector2):
	var block = BLOCK_SCENE.instantiate()
	game_layer.add_child(block)
	block.position = pos
	block.set_block_size(size)
	return block


func _spawn_next_block() -> void:
	color_index += 1
	var spawn_side := -1.0 if color_index % 2 == 0 else 1.0
	var spawn_x := VIEWPORT_SIZE.x * 0.5 + spawn_side * 190.0
	var spawn_y: float = top_block.position.y - DROP_HEIGHT
	active_block = _create_block(Vector2(spawn_x, spawn_y), Vector2(current_width, START_BLOCK_SIZE.y))
	active_block.set_block_color(_block_color(color_index))
	_add_block_glow(active_block)
	move_direction = -spawn_side
	camera_target_y = min(camera_target_y, top_block.position.y - CAMERA_FOLLOW_OFFSET)


func _move_active_block(delta: float) -> void:
	active_block.position.x += move_direction * move_speed * delta

	var half_width: float = active_block.get_width() * 0.5
	var left_limit: float = half_width + 24.0
	var right_limit: float = VIEWPORT_SIZE.x - half_width - 24.0

	if active_block.position.x <= left_limit:
		active_block.position.x = left_limit
		move_direction = 1.0
	elif active_block.position.x >= right_limit:
		active_block.position.x = right_limit
		move_direction = -1.0


func _drop_active_block() -> void:
	dropping = true
	_play_sfx("drop")
	var landing_y: float = top_block.position.y - START_BLOCK_SIZE.y
	var tween := create_tween()
	tween.tween_property(active_block, "position:y", landing_y, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.finished.connect(_resolve_landing)


func _resolve_landing() -> void:
	var previous_left: float = top_block.position.x - top_block.get_width() * 0.5
	var previous_right: float = top_block.position.x + top_block.get_width() * 0.5
	var active_left: float = active_block.position.x - active_block.get_width() * 0.5
	var active_right: float = active_block.position.x + active_block.get_width() * 0.5
	var overlap_left: float = max(previous_left, active_left)
	var overlap_right: float = min(previous_right, active_right)
	var overlap_width: float = overlap_right - overlap_left
	var x_difference: float = abs(active_block.position.x - top_block.position.x)
	var perfect_threshold := _current_perfect_threshold()
	var is_perfect: bool = x_difference <= perfect_threshold
	var is_exact_perfect: bool = x_difference <= _current_exact_perfect_threshold()

	if overlap_width <= 0.0:
		if current_mode_id == MODE_RELAX:
			_handle_relax_miss()
		else:
			_trigger_game_over()
		return

	if is_perfect and current_mode_id == MODE_RELAX:
		overlap_width = top_block.get_width()
		active_block.position.x = top_block.position.x
	else:
		active_block.position.x = (overlap_left + overlap_right) * 0.5

	if is_exact_perfect:
		perfect_combo += 1
		_shake_camera()
		_perfect_glow(active_block)
		_play_sfx("perfect")
		_vibrate(55)
		if perfect_combo > 1:
			_play_sfx("combo")
	else:
		perfect_combo = 0

	var min_block_width := _current_min_block_width()
	if overlap_width < min_block_width:
		if current_mode_id == MODE_RELAX:
			_handle_relax_miss()
		else:
			_trigger_game_over()
		return

	current_width = _current_next_block_width(overlap_width, is_perfect)
	active_block.set_block_size(Vector2(current_width, START_BLOCK_SIZE.y))
	var feedback_pos: Vector2 = active_block.position
	top_block = active_block
	active_block = null

	score += 1
	placements += 1
	if is_exact_perfect:
		score += 1
	_update_perfect_streak_record()
	_update_move_speed()
	_update_best_score()
	_update_relax_progress()
	_unlock_worlds_for_height(true)
	_update_run_world(true)
	_update_score_ui()
	var feedback_tier := _feedback_for_alignment(x_difference)
	_show_landing_feedback(feedback_tier, feedback_pos, _update_feedback_streak(feedback_tier))
	_pop_score()
	_score_popup(top_block.position, 1 if not is_exact_perfect else 2)
	_land_effect(top_block)
	_landing_particles(top_block.position, top_block.get_width(), is_exact_perfect)
	_play_sfx("land")
	if not is_exact_perfect:
		_vibrate(22)

	dropping = false
	_spawn_next_block()


func _trigger_game_over() -> void:
	if current_mode_id == MODE_RELAX:
		_handle_relax_miss()
		return

	if game_over_panel.visible:
		return

	playing = false
	paused = false
	dropping = false
	_play_sfx("game_over")
	_vibrate(90)
	_update_best_score()
	_unlock_worlds_for_height(false)
	_rebuild_theme_buttons()
	_show_game_over()


func _handle_relax_miss() -> void:
	if active_block:
		active_block.queue_free()
		active_block = null

	dropping = false
	perfect_combo = 0
	last_feedback_tier = ""
	current_feedback_streak = 0
	current_width = START_BLOCK_SIZE.x
	_spawn_next_block()


func _show_game_over() -> void:
	if current_mode_id == MODE_RELAX:
		return

	var last_stop := _journey_stop_for_height(placements)
	final_score_label.text = _format_game_over_stats([
		["DISTANCE TRAVELED", _format_distance(_distance_for_height(placements))],
		["LAST CHECKPOINT", String(last_stop["name"])],
		["HIGHEST STACK", "%d BLOCKS" % best_height_blocks],
		["FARTHEST DESTINATION", _furthest_destination_name()],
		["BEST PERFECT STREAK", "%d" % best_perfect_streak],
	])
	game_over_panel.visible = true
	pause_button.visible = false
	pause_menu.visible = false
	_update_continue_button_state("game_over_shown")
	if _can_offer_continue() and not ads_removed:
		if _is_test_ad_mode():
			if ad_manager.show_interstitial_if_needed():
				_show_test_interstitial_ad()
		else:
			ad_manager.show_interstitial_if_needed()
	_debug_continue_game_state("after_interstitial_check")


func _hide_game_over() -> void:
	game_over_panel.visible = false
	pause_menu.visible = false
	_hide_test_ad_overlay()
	_hide_perfect_feedback()
	perfect_label.visible = false
	flash.visible = false
	world_unlock_popup.visible = false


func _on_continue_pressed() -> void:
	_debug_continue_game_state("continue_pressed")
	if current_mode_id == MODE_RELAX:
		return

	if not _can_offer_continue():
		_update_continue_button_state("continue_blocked")
		return

	if waiting_for_reward:
		return

	_play_sfx("button")
	if ads_removed:
		_complete_rewarded_continue()
		return

	if _is_test_ad_mode():
		_show_test_rewarded_ad()
		return

	var rewarded_ready: bool = ad_manager.can_show_rewarded_continue()
	if rewarded_ready:
		waiting_for_reward = true
		rewarded_ad_was_shown = false
		continue_button.disabled = true
		if not ad_manager.show_rewarded_continue():
			waiting_for_reward = false
			_on_rewarded_continue_failed()
	else:
		if not rewarded_ad_was_shown:
			_grant_free_continue_fallback()
		else:
			_on_rewarded_continue_failed()


func _complete_rewarded_continue() -> void:
	waiting_for_reward = false
	rewarded_ad_was_shown = false
	continues_used += 1
	blocks_at_continue = placements
	time_at_continue_ms = Time.get_ticks_msec()
	_hide_test_ad_overlay()
	_hide_game_over()
	pause_button.visible = true
	_restore_after_continue()


func _on_rewarded_continue_completed() -> void:
	waiting_for_reward = false
	rewarded_ad_was_shown = false
	if game_over_panel.visible and _continues_remaining() > 0:
		_complete_rewarded_continue()


func _on_rewarded_continue_failed() -> void:
	var fallback_allowed := waiting_for_reward and not rewarded_ad_was_shown
	waiting_for_reward = false
	if fallback_allowed:
		_grant_free_continue_fallback()
		return
	if game_over_panel.visible and _continues_remaining() > 0:
		_update_continue_button_state("rewarded_failed")


func _on_rewarded_ad_shown() -> void:
	if waiting_for_reward:
		rewarded_ad_was_shown = true


func _grant_free_continue_fallback() -> void:
	if not game_over_panel.visible or _continues_remaining() <= 0:
		return
	print("ADMOB FLOW: rewarded unavailable, granting fallback continue")
	_complete_rewarded_continue()


func _on_rewarded_ad_state_changed() -> void:
	if game_over_panel.visible and _continues_remaining() > 0:
		_update_continue_button_state("rewarded_state_changed")


func _on_continue_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_debug_continue_game_state("continue_mouse_input")
	elif event is InputEventScreenTouch and event.pressed:
		_debug_continue_game_state("continue_touch_input")


func _update_continue_button_state(reason: String) -> void:
	var remaining := _continues_remaining()
	var eligible := _is_continue_eligible()
	continue_button.visible = true
	continue_helper_label.visible = false

	if remaining <= 0:
		continue_button.disabled = true
		continue_button.text = "NO CONTINUES LEFT"
		_debug_continue_game_state(reason)
		return

	if not eligible:
		continue_button.disabled = true
		continue_button.text = "CONTINUE LOCKED"
		continue_helper_label.visible = true
		_debug_continue_game_state(reason)
		return

	if ads_removed:
		continue_button.disabled = false
		continue_button.text = _continue_button_text()
		_debug_continue_game_state(reason)
		return

	if _is_test_ad_mode():
		continue_button.disabled = false
		continue_button.text = _continue_button_text()
		_debug_continue_game_state(reason)
		return

	continue_button.disabled = false
	continue_button.text = _continue_button_text()

	_debug_continue_game_state(reason)


func _continues_remaining() -> int:
	return max(0, max_continues - continues_used)


func _can_offer_continue() -> bool:
	return _continues_remaining() > 0 and _is_continue_eligible()


func _is_continue_eligible() -> bool:
	if continues_used == 0:
		return true
	return _blocks_since_continue() >= 10 or _seconds_since_continue() >= 20.0


func _blocks_since_continue() -> int:
	return max(0, placements - blocks_at_continue)


func _seconds_since_continue() -> float:
	if time_at_continue_ms == 0:
		return 0.0
	return float(Time.get_ticks_msec() - time_at_continue_ms) / 1000.0


func _continue_button_text() -> String:
	return "CONTINUE GAME (%d/%d left)" % [_continues_remaining(), max_continues]


func _debug_continue_game_state(context: String) -> void:
	var rewarded_ready: bool = ad_manager.can_show_rewarded_continue() if ad_manager else false
	var rewarded_loading: bool = ad_manager.has_method("is_rewarded_ad_loading") and ad_manager.is_rewarded_ad_loading()
	var rewarded_failed: bool = ad_manager.has_method("did_rewarded_ad_load_fail") and ad_manager.did_rewarded_ad_load_fail()
	var rewarded_error := ""
	if ad_manager.has_method("rewarded_ad_error"):
		rewarded_error = ad_manager.rewarded_ad_error()
	var rewarded_ad_unit_id := ""
	if ad_manager.has_method("rewarded_ad_unit_id"):
		rewarded_ad_unit_id = ad_manager.rewarded_ad_unit_id()
	var blocking_overlays := _visible_ad_blocking_overlays()
	print(
		"CONTINUE DEBUG [", context, "] ",
		"visible=", continue_button.visible,
		" disabled=", continue_button.disabled,
		" text=\"", continue_button.text, "\"",
		" ads_removed=", ads_removed,
		" TEST_AD_MODE=", ad_manager.is_test_ad_mode() if ad_manager.has_method("is_test_ad_mode") else "unknown",
		" USE_ADMOB_SAMPLE_ADS=", ad_manager.is_using_admob_sample_ads() if ad_manager.has_method("is_using_admob_sample_ads") else "unknown",
		" rewarded_ad_unit_id=", rewarded_ad_unit_id,
		" rewarded_ready=", rewarded_ready,
		" rewarded_loading=", rewarded_loading,
		" rewarded_load_failed=", rewarded_failed,
		" rewarded_error=\"", rewarded_error, "\"",
		" continues_used=", continues_used,
		" continues_remaining=", _continues_remaining(),
		" continue_eligible=", _is_continue_eligible(),
		" blocks_since_continue=", _blocks_since_continue(),
		" seconds_since_continue=", "%.2f" % _seconds_since_continue(),
		" disabled_because_not_ready=", continue_button.disabled and not ads_removed and _can_offer_continue() and not rewarded_ready,
		" blocking_overlays=", blocking_overlays
	)


func _visible_ad_blocking_overlays() -> Array[String]:
	var overlays: Array[String] = []
	if test_ad_overlay.visible:
		overlays.append("TestAdOverlay")
	if pause_menu.visible:
		overlays.append("PauseMenu")
	if theme_menu.visible:
		overlays.append("UniverseMap")
	if settings_panel.visible:
		overlays.append("Settings")
	if title_screen.visible:
		overlays.append("TitleScreen")
	if world_unlock_popup.visible:
		overlays.append("WorldUnlockPopup")
	return overlays


func _is_test_ad_mode() -> bool:
	return ad_manager and ad_manager.has_method("is_test_ad_mode") and ad_manager.is_test_ad_mode()


func _show_test_interstitial_ad() -> void:
	pending_test_ad_kind = "interstitial"
	test_ad_title_label.text = "TEST INTERSTITIAL AD"
	test_ad_close_button.visible = true
	test_ad_complete_button.visible = false
	test_ad_fail_button.visible = false
	test_ad_overlay.visible = true


func _show_test_rewarded_ad() -> void:
	pending_test_ad_kind = "rewarded"
	test_ad_title_label.text = "TEST REWARDED AD"
	test_ad_close_button.visible = false
	test_ad_complete_button.visible = true
	test_ad_fail_button.visible = true
	test_ad_overlay.visible = true


func _hide_test_ad_overlay() -> void:
	pending_test_ad_kind = ""
	test_ad_overlay.visible = false


func _on_test_interstitial_closed() -> void:
	if pending_test_ad_kind != "interstitial":
		return
	_play_sfx("button")
	_hide_test_ad_overlay()


func _on_test_reward_completed() -> void:
	if pending_test_ad_kind != "rewarded":
		return
	_play_sfx("button")
	_complete_rewarded_continue()


func _on_test_reward_failed() -> void:
	if pending_test_ad_kind != "rewarded":
		return
	_play_sfx("button")
	_hide_test_ad_overlay()


func _restore_after_continue() -> void:
	if active_block:
		active_block.queue_free()

	perfect_combo = 0
	last_feedback_tier = ""
	current_feedback_streak = 0
	current_width = max(top_block.get_width(), MIN_BLOCK_WIDTH * 2.0)
	_update_move_speed()
	_spawn_next_block()
	playing = true
	dropping = false


func _on_restart_pressed() -> void:
	_play_sfx("button")
	_start_new_run()


func _on_pause_restart_pressed() -> void:
	_play_sfx("button")
	_start_new_run()


func _on_play_pressed() -> void:
	_play_sfx("button")
	_select_mode_and_start(MODE_MISSION)


func _on_relax_pressed() -> void:
	_play_sfx("button")
	_select_mode_and_start(MODE_RELAX)


func _on_back_to_title_pressed() -> void:
	_play_sfx("button")
	_show_title_screen()


func _select_mode_and_start(mode_id: String) -> void:
	selected_mode_id = mode_id
	_save_best_score()
	_update_mode_ui()
	_start_new_run()


func _update_mode_ui() -> void:
	if not is_instance_valid(mode_label):
		return

	mode_label.text = ""
	mode_label.visible = false
	mode_subtitle_label.text = "Slowly travel through the universe" if selected_mode_id == MODE_RELAX else ""
	play_button.modulate = Color.WHITE
	relax_button.modulate = Color.WHITE


func _mode_display_name(mode_id: String) -> String:
	return "RELAX JOURNEY" if mode_id == MODE_RELAX else "GAME MODE"


func _show_title_screen() -> void:
	on_title_screen = true
	playing = false
	paused = false
	dropping = false
	dashboard_message_locked = false
	last_feedback_tier = ""
	current_feedback_streak = 0
	_hide_perfect_feedback()
	top_bar.visible = false
	pause_button.visible = false
	pause_menu.visible = false
	game_over_panel.visible = false
	theme_menu.visible = false
	settings_panel.visible = false
	title_screen.visible = true
	title_best_label.text = _best_height_text()
	_update_mode_ui()


func _show_theme_menu() -> void:
	_play_sfx("button")
	map_mode_id = selected_mode_id
	if map_mode_id != MODE_RELAX:
		map_mode_id = MODE_MISSION
	selected_map_entry_id = ""
	pause_menu.visible = false
	title_screen.visible = false
	settings_panel.visible = false
	theme_menu.visible = true
	_rebuild_theme_buttons()


func _show_settings() -> void:
	_play_sfx("button")
	settings_return_to_pause = paused
	title_screen.visible = false
	theme_menu.visible = false
	pause_menu.visible = false
	settings_panel.visible = true


func _on_settings_back_pressed() -> void:
	_play_sfx("button")
	settings_panel.visible = false
	if settings_return_to_pause and playing and paused:
		pause_menu.visible = true
	else:
		_show_title_screen()


func _show_pause_menu() -> void:
	if not playing or game_over_panel.visible:
		return

	_play_sfx("button")
	paused = true
	_hide_perfect_feedback()
	pause_button.visible = false
	pause_menu.visible = true


func _resume_game() -> void:
	_play_sfx("button")
	paused = false
	settings_panel.visible = false
	pause_menu.visible = false
	pause_button.visible = playing and not game_over_panel.visible and not on_title_screen


func _go_to_main_menu() -> void:
	_play_sfx("button")
	_update_best_score()
	_unlock_worlds_for_height(false)
	_rebuild_theme_buttons()
	_clear_blocks()
	_show_title_screen()


func _update_score_ui() -> void:
	score_label.text = "%d" % placements
	best_score_label.text = "BLOCKS"
	title_best_label.text = _best_height_text()
	target_distance_km = _distance_for_height(placements)


func _update_move_speed() -> void:
	if current_mode_id == MODE_RELAX:
		var relax_progress: float = clamp(float(placements) / 320.0, 0.0, 1.0)
		move_speed = RELAX_MOVE_SPEED + RELAX_MAX_SPEED_BONUS * pow(relax_progress, 2.4)
		return

	var progress: float = clamp(float(placements) / PLUTO_HEIGHT, 0.0, 1.0)
	move_speed = MOVE_SPEED + MAX_SPEED_BONUS * pow(progress, 1.7)


func _current_move_speed() -> float:
	if current_mode_id == MODE_RELAX:
		return RELAX_MOVE_SPEED
	return MOVE_SPEED


func _current_perfect_threshold() -> float:
	if current_mode_id == MODE_RELAX:
		return RELAX_PERFECT_THRESHOLD
	return PERFECT_THRESHOLD


func _current_exact_perfect_threshold() -> float:
	if current_mode_id == MODE_RELAX:
		return RELAX_PERFECT_EXACT_THRESHOLD
	return PERFECT_EXACT_THRESHOLD


func _current_min_block_width() -> float:
	if current_mode_id == MODE_RELAX:
		return RELAX_MIN_BLOCK_WIDTH
	return MIN_BLOCK_WIDTH


func _current_next_block_width(overlap_width: float, is_perfect: bool) -> float:
	if current_mode_id == MODE_RELAX:
		return START_BLOCK_SIZE.x
	return overlap_width


func _update_best_score() -> void:
	if current_mode_id != MODE_MISSION:
		return

	if score <= best_score:
		if placements <= best_height_blocks:
			_update_furthest_destination_record()
			return
	else:
		best_score = score

	if placements > best_height_blocks:
		best_height_blocks = placements
	_update_furthest_destination_record()
	_save_best_score()


func _update_furthest_destination_record() -> void:
	var stop := _journey_stop_for_height(placements)
	var stop_height := int(stop["height"])
	if stop_height > best_destination_height:
		best_destination_height = stop_height


func _update_relax_progress() -> void:
	if current_mode_id != MODE_RELAX:
		return

	var changed := false
	if placements > best_relax_height_blocks:
		best_relax_height_blocks = placements
		changed = true

	var stop := _journey_stop_for_height(placements)
	var stop_height := int(stop["height"])
	if stop_height > best_relax_destination_height:
		best_relax_destination_height = stop_height
		changed = true

	if changed:
		_save_best_score()


func _update_perfect_streak_record() -> void:
	if current_mode_id != MODE_MISSION:
		return
	if perfect_combo > best_perfect_streak:
		best_perfect_streak = perfect_combo
		_save_best_score()


func _furthest_destination_name() -> String:
	return String(_journey_stop_for_height(best_destination_height)["name"])


func _format_game_over_stats(rows: Array) -> String:
	var parts: Array[String] = []
	for row in rows:
		parts.append("[center][color=#2ff4ff]%s[/color]\n[color=#ffffff]%s[/color][/center]" % [String(row[0]), String(row[1])])
	return "\n".join(parts)


func _best_height_text() -> String:
	return "BEST HEIGHT\n%d BLOCKS" % best_height_blocks


func _feedback_for_alignment(x_difference: float) -> String:
	var threshold := _current_perfect_threshold()
	var exact_threshold := RELAX_PERFECT_EXACT_THRESHOLD if current_mode_id == MODE_RELAX else PERFECT_EXACT_THRESHOLD
	if x_difference <= exact_threshold:
		return "PERFECT"
	if x_difference <= threshold * 0.75:
		return "AMAZING"
	if x_difference <= threshold * 1.5:
		return "AWESOME"
	if x_difference <= threshold * 2.75:
		return "GREAT"
	return "NICE"


func _update_feedback_streak(text: String) -> int:
	if text == last_feedback_tier:
		current_feedback_streak += 1
	else:
		last_feedback_tier = text
		current_feedback_streak = 1
	return current_feedback_streak


func _show_landing_feedback(text: String, world_pos: Vector2, streak: int = 0) -> void:
	_hide_perfect_feedback()

	var label := Label.new()
	var feedback_size := Vector2(360.0, 64.0)
	var display_text := text
	if streak > 1:
		display_text = "%s ×%d" % [text, streak]
	label.text = display_text
	label.size = feedback_size
	label.pivot_offset = feedback_size * 0.5
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 36 if current_mode_id == MODE_MISSION else 32)
	label.add_theme_color_override("font_color", _feedback_color(text))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.55))
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 3)
	label.modulate.a = 0.0
	label.scale = Vector2(0.84, 0.84)
	perfect_label.get_parent().add_child(label)

	var screen_pos := _world_to_screen(world_pos)
	var dashboard_bottom := top_bar.offset_bottom + 16.0
	var feedback_y_offset := START_BLOCK_SIZE.y * camera.zoom.y * 3.0
	var target_pos := Vector2(screen_pos.x - feedback_size.x * 0.5, screen_pos.y - feedback_y_offset)
	target_pos.x = clamp(target_pos.x, 16.0, VIEWPORT_SIZE.x - feedback_size.x - 16.0)
	target_pos.y = clamp(target_pos.y, dashboard_bottom, VIEWPORT_SIZE.y - feedback_size.y - 24.0)
	label.position = target_pos
	perfect_feedback_node = label

	perfect_feedback_tween = create_tween()
	perfect_feedback_tween.tween_property(label, "modulate:a", 0.9 if current_mode_id == MODE_MISSION else 0.78, 0.1)
	perfect_feedback_tween.parallel().tween_property(label, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	perfect_feedback_tween.tween_interval(0.54 if current_mode_id == MODE_MISSION else 0.66)
	perfect_feedback_tween.tween_property(label, "modulate:a", 0.0, 0.22)
	perfect_feedback_tween.parallel().tween_property(label, "scale", Vector2(0.98, 0.98), 0.22)
	perfect_feedback_tween.finished.connect(func() -> void:
		if is_instance_valid(label):
			label.queue_free()
		if perfect_feedback_node == label:
			perfect_feedback_node = null
	)


func _feedback_color(text: String) -> Color:
	match text:
		"NICE":
			return Color(0.46, 1.0, 0.95, 1.0)
		"GREAT":
			return Color(0.32, 0.78, 1.0, 1.0)
		"AWESOME":
			return Color(0.78, 0.42, 1.0, 1.0)
		"AMAZING":
			return Color(1.0, 0.28, 0.78, 1.0)
		"PERFECT":
			return Color(1.0, 0.86, 0.2, 1.0)
	return Color(1.0, 0.84, 0.22, 1.0)


func _world_to_screen(world_pos: Vector2) -> Vector2:
	return (world_pos - camera.position) * camera.zoom + VIEWPORT_SIZE * 0.5 + camera.offset


func _hide_perfect_feedback() -> void:
	if perfect_feedback_tween and perfect_feedback_tween.is_valid():
		perfect_feedback_tween.kill()
	if is_instance_valid(perfect_feedback_node):
		perfect_feedback_node.queue_free()
	perfect_feedback_node = null
	perfect_label.visible = false
	perfect_label.position = Vector2.ZERO
	perfect_label.modulate.a = 0.0


func _land_effect(block) -> void:
	block.scale = Vector2(1.1, 0.86) if current_mode_id == MODE_RELAX else Vector2(1.1, 0.82)
	var tween := create_tween()
	if current_mode_id == MODE_RELAX:
		tween.tween_property(block, "scale", Vector2(0.98, 1.04), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(block, "scale", Vector2(0.96, 1.08), 0.07).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(block, "scale", Vector2.ONE, 0.11).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _pop_score() -> void:
	score_label.pivot_offset = score_label.size * 0.5
	score_label.scale = Vector2(1.22, 1.22)
	var tween := create_tween()
	tween.tween_property(score_label, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _flash_screen() -> void:
	flash.visible = true
	flash.color = _theme_particle_color()
	flash.modulate.a = 0.82 if current_mode_id == MODE_MISSION else 0.34
	var tween := create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.08 if current_mode_id == MODE_RELAX else 0.12)
	tween.finished.connect(func() -> void: flash.visible = false)


func _shake_camera() -> void:
	var original_offset := camera.offset
	var tween := create_tween()
	if current_mode_id == MODE_RELAX:
		tween.tween_property(camera, "offset", Vector2(2.0, -1.5), 0.03)
		tween.tween_property(camera, "offset", Vector2(-1.5, 1.0), 0.03)
	else:
		tween.tween_property(camera, "offset", Vector2(7.0, -5.0), 0.035)
		tween.tween_property(camera, "offset", Vector2(-5.0, 4.0), 0.035)
	tween.tween_property(camera, "offset", original_offset, 0.035)


func _score_popup(world_pos: Vector2, amount: int) -> void:
	var label := Label.new()
	label.text = "+%d" % amount
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", _theme_particle_color())
	label.add_theme_font_size_override("font_size", 26)
	effects_layer.add_child(label)
	label.position = world_pos + Vector2(-30.0, -74.0)

	var tween := create_tween()
	tween.tween_property(label, "position:y", label.position.y - 44.0, 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.42)
	tween.finished.connect(label.queue_free)


func _landing_particles(world_pos: Vector2, width: float, perfect: bool) -> void:
	var count := 8 if perfect else 5
	for index in count:
		var particle := ColorRect.new()
		particle.size = Vector2(8.0, 8.0)
		particle.color = _theme_particle_color() if perfect else Color(1, 1, 1, 0.58)
		effects_layer.add_child(particle)
		particle.position = world_pos + Vector2(randf_range(-width * 0.45, width * 0.45), -10.0)
		var target := particle.position + Vector2(randf_range(-34.0, 34.0), randf_range(-42.0, -14.0))
		var tween := create_tween()
		tween.tween_property(particle, "position", target, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(particle, "modulate:a", 0.0, 0.28)
		tween.finished.connect(particle.queue_free)


func _perfect_glow(block) -> void:
	var glow := Panel.new()
	glow.size = Vector2(block.get_width() + 18.0, block.get_height() + 14.0)
	glow.position = block.position - glow.size * 0.5
	glow.modulate.a = 0.13
	_apply_glow_style(glow, _theme_particle_color(), 10)
	effects_layer.add_child(glow)

	var tween := create_tween()
	tween.tween_property(glow, "scale", Vector2(1.06, 1.16), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(glow, "modulate:a", 0.0, 0.1)
	tween.finished.connect(glow.queue_free)


func _show_world_unlock_popup(world_name: String) -> void:
	unlock_world_label.text = world_name
	world_unlock_popup.visible = true
	world_unlock_popup.modulate.a = 1.0
	world_unlock_popup.scale = Vector2(0.88, 0.88)

	var tween := create_tween()
	tween.tween_property(world_unlock_popup, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(1.05)
	tween.tween_property(world_unlock_popup, "modulate:a", 0.0, 0.2)
	tween.finished.connect(func() -> void: world_unlock_popup.visible = false)


func _setup_floating_particles() -> void:
	for index in 42:
		var dot := ColorRect.new()
		var size := randf_range(2.0, 6.0)
		dot.size = Vector2(size, size)
		dot.color = Color(1, 1, 1, randf_range(0.16, 0.42))
		float_particles.add_child(dot)
		var data := {
			"node": dot,
			"speed": randf_range(10.0, 26.0),
			"drift": randf_range(-10.0, 10.0),
		}
		floating_dots.append(data)
		dot.position = Vector2(randf_range(20.0, VIEWPORT_SIZE.x - 20.0), randf_range(0.0, VIEWPORT_SIZE.y))


func _update_floating_particles(delta: float) -> void:
	for data in floating_dots:
		var dot: ColorRect = data["node"]
		dot.position.y -= data["speed"] * delta
		dot.position.x += data["drift"] * delta
		if dot.position.y < -20.0:
			dot.position.y = VIEWPORT_SIZE.y + 20.0
			dot.position.x = randf_range(20.0, VIEWPORT_SIZE.x - 20.0)


func _block_color(index: int) -> Color:
	var colors: Array = current_theme["blocks"]
	return colors[index % colors.size()]


func _theme_particle_color() -> Color:
	return current_theme.get("particle", Color(0.2, 0.95, 1.0))


func _add_block_glow(block) -> void:
	# A cheap neon halo: one transparent rectangle behind each block.
	var glow := Panel.new()
	glow.name = "Glow"
	glow.show_behind_parent = true
	glow.size = Vector2(block.get_width() + 22.0, block.get_height() + 16.0)
	glow.position = -glow.size * 0.5
	glow.modulate.a = 0.16
	_apply_glow_style(glow, block.block_color, 12)
	block.add_child(glow)


func _apply_glow_style(panel: Panel, color: Color, radius: int) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	panel.add_theme_stylebox_override("panel", style)


func _apply_selected_theme() -> void:
	_apply_theme_by_id(selected_theme_id)


func _apply_theme_by_id(theme_id: String) -> void:
	current_theme = _theme_by_id(theme_id)
	gradient_top.color = current_theme["top"]
	gradient_bottom.color = current_theme["bottom"]
	flash.color = _theme_particle_color()
	for data in floating_dots:
		var dot: ColorRect = data["node"]
		var color := _theme_particle_color()
		color.a = randf_range(0.15, 0.45)
		dot.color = color


func _theme_by_id(theme_id: String) -> Dictionary:
	for theme in THEMES:
		if theme["id"] == theme_id:
			return theme
	return THEMES[0]


func _is_theme_unlocked(theme_id: String) -> bool:
	return unlocked_theme_ids.has(theme_id)


func _unlock_worlds_for_height(show_popup: bool) -> void:
	var changed := false
	for theme in THEMES:
		if best_height_blocks >= theme["unlock"] and not unlocked_theme_ids.has(theme["id"]):
			unlocked_theme_ids.append(theme["id"])
			changed = true
	if changed:
		_save_best_score()


func _update_run_world(show_popup: bool) -> void:
	var stop := _journey_stop_for_height(placements)
	var next_journey_id := String(stop["id"])
	if next_journey_id != active_journey_id:
		active_journey_id = next_journey_id
		if show_popup:
			_apply_journey_palette(stop)
			_show_checkpoint_reached(stop)
			_play_sfx("combo")
		else:
			_update_journey_display(stop)

	var final_stop_height := int(JOURNEY_STOPS[JOURNEY_STOPS.size() - 1]["height"])
	if placements > final_stop_height and placements % 100 == 0:
		var discovery_index := placements / 100 - 2
		if discovery_index > last_discovery_index:
			last_discovery_index = discovery_index
			_show_deep_space_discovery(discovery_index)


func _journey_stop_for_height(height: int) -> Dictionary:
	var stop: Dictionary = JOURNEY_STOPS[0]
	for candidate in JOURNEY_STOPS:
		if height >= candidate["height"]:
			stop = candidate
	return stop


func _journey_destination_for_height(height: int) -> Dictionary:
	for stop in JOURNEY_STOPS:
		if height < stop["height"]:
			return stop

	return {
		"height": 999999,
		"id": "unknown",
		"icon": "♾️",
		"name": "UNKNOWN",
		"distance": float(JOURNEY_STOPS[JOURNEY_STOPS.size() - 1]["distance"]) + KM_PER_LIGHT_YEAR * 1000000.0,
	}


func _update_journey_display(stop: Dictionary) -> void:
	var destination := _journey_destination_for_height(placements)
	journey_icon_label.text = String(destination["icon"])
	journey_name_label.text = String(destination["name"])
	journey_checkpoint_label.text = "LAST CHECKPOINT: %s" % String(stop["name"])
	target_distance_km = _distance_for_height(placements)
	journey_subtitle_label.text = _format_distance(displayed_distance_km)
	_apply_dashboard_atmosphere(stop)


func _show_checkpoint_reached(stop: Dictionary) -> void:
	if String(stop["id"]) == "oort_cloud":
		_show_leaving_solar_system_moment(stop)
		return

	journey_icon_label.text = String(stop["icon"])
	journey_name_label.text = "%s REACHED" % String(stop["name"])
	journey_checkpoint_label.text = "LAST CHECKPOINT: %s" % String(stop["name"])
	_pulse_dashboard()

	var tween := create_tween()
	tween.tween_interval(0.45)
	tween.tween_callback(func() -> void:
		if playing and not on_title_screen:
			_update_journey_display(_journey_stop_for_height(placements))
	)


func _show_leaving_solar_system_moment(stop: Dictionary) -> void:
	dashboard_message_locked = true
	journey_icon_label.text = String(stop["icon"])
	journey_name_label.text = "LEAVING THE SOLAR SYSTEM"
	journey_subtitle_label.text = "PLUTO PASSED"
	journey_checkpoint_label.text = "NEXT DESTINATION: ALPHA CENTAURI"
	_pulse_dashboard()
	_solar_system_exit_particles()

	var tween := create_tween()
	tween.tween_property(space_window_tint, "color", Color(0.22, 0.06, 0.42, 0.13), 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(horizon_line, "color", Color(0.65, 0.34, 1.0, 0.08), 0.75)
	tween.tween_interval(0.25)
	tween.tween_callback(func() -> void:
		dashboard_message_locked = false
		if playing and not on_title_screen:
			_update_journey_display(stop)
	)


func _solar_system_exit_particles() -> void:
	for index in 12:
		var particle := ColorRect.new()
		var size := randf_range(3.0, 6.0)
		particle.size = Vector2(size, size)
		particle.color = Color(0.72, 0.95, 1.0, 0.58)
		particle.position = Vector2(randf_range(170.0, 550.0), randf_range(190.0, 380.0))
		effects_layer.add_child(particle)

		var target := particle.position + Vector2(randf_range(-24.0, 24.0), randf_range(-54.0, -18.0))
		var tween := create_tween()
		tween.tween_property(particle, "position", target, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(particle, "modulate:a", 0.0, 0.55)
		tween.finished.connect(particle.queue_free)


func _update_distance_counter(delta: float) -> void:
	if abs(displayed_distance_km - target_distance_km) < 1.0:
		displayed_distance_km = target_distance_km
	else:
		displayed_distance_km = lerp(displayed_distance_km, target_distance_km, min(1.0, delta * 5.5))

	if not dashboard_message_locked:
		journey_subtitle_label.text = _format_distance(displayed_distance_km)


func _distance_for_height(height: int) -> float:
	var current: Dictionary = JOURNEY_STOPS[0]
	var next: Dictionary = JOURNEY_STOPS[JOURNEY_STOPS.size() - 1]

	for index in JOURNEY_STOPS.size():
		var stop: Dictionary = JOURNEY_STOPS[index]
		if height >= stop["height"]:
			current = stop
			if index < JOURNEY_STOPS.size() - 1:
				next = JOURNEY_STOPS[index + 1]
			else:
				next = stop

	if current == next:
		var extra_blocks: int = max(0, height - int(current["height"]))
		var step := 50000000.0
		if float(current["distance"]) >= KM_PER_LIGHT_YEAR:
			step = KM_PER_LIGHT_YEAR * 1000000.0
		return float(current["distance"]) + extra_blocks * step

	var span: float = max(1.0, float(next["height"] - current["height"]))
	var progress: float = clamp(float(height - current["height"]) / span, 0.0, 1.0)
	return lerp(float(current["distance"]), float(next["distance"]), progress)


func _format_distance(distance: float) -> String:
	if distance >= KM_PER_LIGHT_YEAR:
		var light_years := distance / KM_PER_LIGHT_YEAR
		if light_years >= 1000000.0:
			return "%.1f MILLION LIGHT YEARS" % (light_years / 1000000.0)
		if light_years >= 1000.0:
			return "%.1f THOUSAND LIGHT YEARS" % (light_years / 1000.0)
		return "%.1f LIGHT YEARS" % light_years
	if distance >= 1000000000000.0:
		return "%.1f TRILLION KM" % (distance / 1000000000000.0)
	if distance >= 1000000000.0:
		return "%.1f BILLION KM" % (distance / 1000000000.0)
	if distance >= 1000000.0:
		return "%.1f MILLION KM" % (distance / 1000000.0)
	return "%s KM" % _format_int_with_commas(int(round(distance)))


func _format_int_with_commas(value: int) -> String:
	var text := str(value)
	var result := ""
	var count := 0
	for index in range(text.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = text[index] + result
		count += 1
	return result


func _pulse_dashboard() -> void:
	top_bar.modulate = Color(1.0, 1.0, 1.0, 1.0)
	top_bar.scale = Vector2(1.02, 1.02)
	var tween := create_tween()
	tween.tween_property(top_bar, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(top_bar, "modulate", Color(0.86, 0.96, 1.0, 1.0), 0.28)


func _apply_dashboard_atmosphere(stop: Dictionary) -> void:
	var journey_id := String(stop["id"])
	var tint := Color(0.08, 0.28, 0.85, 0.08)
	var body_color := Color(0.25, 0.62, 1.0, 0.2)
	var body_rect := Rect2(Vector2(472.0, 118.0), Vector2(200.0, 200.0))
	var ring_visible := false
	var horizon_color := Color(0.35, 0.72, 1.0, 0.14)

	match journey_id:
		"earth":
			tint = Color(0.12, 0.45, 0.9, 0.1)
			body_color = Color(0.2, 0.58, 1.0, 0.24)
			horizon_color = Color(0.48, 0.82, 1.0, 0.18)
		"moon":
			tint = Color(0.12, 0.14, 0.22, 0.08)
			body_color = Color(0.22, 0.5, 1.0, 0.2)
			body_rect = Rect2(Vector2(94.0, 150.0), Vector2(86.0, 86.0))
			horizon_color = Color(0.9, 0.94, 1.0, 0.08)
		"mars":
			tint = Color(0.8, 0.18, 0.08, 0.1)
			body_color = Color(0.95, 0.24, 0.08, 0.2)
			horizon_color = Color(1.0, 0.42, 0.22, 0.12)
		"jupiter":
			tint = Color(0.82, 0.42, 0.16, 0.08)
			body_color = Color(0.9, 0.58, 0.3, 0.22)
			body_rect = Rect2(Vector2(430.0, 88.0), Vector2(290.0, 290.0))
		"saturn":
			tint = Color(0.9, 0.64, 0.22, 0.07)
			body_color = Color(0.94, 0.72, 0.36, 0.2)
			body_rect = Rect2(Vector2(438.0, 116.0), Vector2(220.0, 220.0))
			ring_visible = true
		"uranus", "neptune":
			tint = Color(0.08, 0.34, 0.88, 0.09)
			body_color = Color(0.12, 0.58, 1.0, 0.2)
		"pluto":
			tint = Color(0.58, 0.78, 1.0, 0.055)
			body_color = Color(0.82, 0.92, 1.0, 0.16)
			body_rect = Rect2(Vector2(516.0, 138.0), Vector2(118.0, 118.0))
		"oort_cloud", "alpha_centauri", "proxima_b", "trappist_worlds":
			tint = Color(0.18, 0.08, 0.42, 0.09)
			body_color = Color(0.42, 0.18, 0.88, 0.14)
			horizon_color = Color(0.46, 0.28, 1.0, 0.09)
		"interstellar_space", "orion_arm", "milky_way", "andromeda", "deep_void", "infinity":
			tint = Color(0.38, 0.08, 0.68, 0.1)
			body_color = Color(0.6, 0.22, 0.95, 0.13)
			horizon_color = Color(0.7, 0.38, 1.0, 0.11)

	space_window_tint.color = tint
	horizon_line.color = horizon_color
	distant_ring.visible = ring_visible
	_style_space_body(distant_body, body_rect, body_color)


func _style_space_body(panel: Panel, rect: Rect2, color: Color) -> void:
	panel.position = rect.position
	panel.size = rect.size
	panel.modulate.a = color.a
	var style := StyleBoxFlat.new()
	style.bg_color = Color(color.r, color.g, color.b, 1.0)
	style.set_corner_radius_all(int(min(rect.size.x, rect.size.y) * 0.5))
	panel.add_theme_stylebox_override("panel", style)


func _show_deep_space_discovery(discovery_index: int) -> void:
	_pulse_dashboard()
	_play_sfx("combo")


func _apply_journey_palette(stop: Dictionary) -> void:
	var journey_id := String(stop["id"])
	var theme_id := "earth_orbit"
	if journey_id in ["mars", "jupiter"]:
		theme_id = "mars_dust"
	elif journey_id in ["moon", "low_orbit", "neptune", "pluto"]:
		theme_id = "europa_ice"
	elif journey_id in [
		"saturn",
		"oort_cloud",
		"alpha_centauri",
		"proxima_b",
		"trappist_worlds",
		"interstellar_space",
		"orion_arm",
		"milky_way",
		"andromeda",
		"deep_void",
		"infinity",
	]:
		theme_id = "the_void"

	active_world_id = theme_id
	_apply_theme_by_id(active_world_id)


func _shake_camera_small() -> void:
	var original_offset := camera.offset
	var tween := create_tween()
	tween.tween_property(camera, "offset", Vector2(3.0, -2.0), 0.04)
	tween.tween_property(camera, "offset", Vector2(-2.0, 2.0), 0.04)
	tween.tween_property(camera, "offset", original_offset, 0.04)


func _rebuild_theme_buttons() -> void:
	for child in theme_list.get_children():
		child.queue_free()

	_update_map_toggle_buttons()

	var entries: Array[Dictionary] = _universe_map_entries()
	var row_height := 118.0
	var width := 660.0
	var total_height: float = max(640.0, row_height * entries.size() + 90.0)
	theme_list.custom_minimum_size = Vector2(width, total_height)
	theme_list.size = Vector2(width, total_height)

	var progress_height: int = _map_progress_height()
	var current_height := int(_journey_stop_for_height(progress_height)["height"])
	var points: PackedVector2Array = []
	map_last_scroll_index = -1

	for index in entries.size():
		var entry: Dictionary = entries[index]
		var y := 52.0 + index * row_height
		var x := 310.0 + sin(float(index) * 0.92) * 112.0
		points.append(Vector2(x, y))

	var route_line := Line2D.new()
	route_line.width = 3.0
	route_line.default_color = Color(0.28, 0.78, 1.0, 0.22)
	route_line.points = points
	theme_list.add_child(route_line)

	for index in entries.size():
		var entry: Dictionary = entries[index]
		var state := _map_entry_state(entry, progress_height, current_height)
		_add_universe_map_entry(entry, points[index], state)

	_update_map_info_label()
	call_deferred("_scroll_universe_map_to_progress")


func _set_map_mode(mode_id: String) -> void:
	_play_sfx("button")
	map_mode_id = mode_id
	selected_map_entry_id = ""
	_rebuild_theme_buttons()


func _update_map_toggle_buttons() -> void:
	var start_selected := map_mode_id == MODE_MISSION
	_apply_button_style(
		map_start_button,
		Color(0.08, 0.9, 1.0, 0.92) if start_selected else Color(0.05, 0.08, 0.15, 0.72),
		Color(0.74, 1.0, 1.0, 0.86) if start_selected else Color(0.2, 0.95, 1.0, 0.34),
		Color(0.03, 0.18, 0.24, 1.0) if start_selected else Color(0.82, 0.95, 1.0, 1.0),
		3 if start_selected else 2
	)
	var relax_selected := map_mode_id == MODE_RELAX
	_apply_button_style(
		map_relax_button,
		Color(0.72, 0.38, 1.0, 0.92) if relax_selected else Color(0.05, 0.08, 0.15, 0.72),
		Color(0.9, 0.7, 1.0, 0.86) if relax_selected else Color(0.72, 0.38, 1.0, 0.34),
		Color(0.08, 0.03, 0.14, 1.0) if relax_selected else Color(0.92, 0.88, 1.0, 1.0),
		3 if relax_selected else 2
	)


func _universe_map_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for stop in JOURNEY_STOPS:
		if String(stop["id"]) == "oort_cloud":
			entries.append({
				"height": int(stop["height"]),
				"id": "leaving_solar_system",
				"icon": "🚀",
				"name": "LEAVING THE SOLAR SYSTEM",
				"transition": true,
			})
		if String(stop["id"]) == "andromeda":
			entries.append({
				"height": 400,
				"id": "leaving_galaxy",
				"icon": "🌌",
				"name": "LEAVING THE GALAXY",
				"transition": true,
			})
		entries.append(stop)
	return entries


func _map_progress_height() -> int:
	return best_relax_height_blocks if map_mode_id == MODE_RELAX else best_height_blocks


func _map_entry_state(entry: Dictionary, progress_height: int, current_height: int) -> String:
	var height := int(entry["height"])
	if entry.get("transition", false) == true:
		return "reached" if progress_height >= height else "future"
	if height == current_height:
		return "current"
	if height < current_height:
		return "reached"
	return "future"


func _add_universe_map_entry(entry: Dictionary, center: Vector2, state: String) -> void:
	var color := _destination_color(String(entry["id"]))
	var node_size := 74.0
	if state == "current":
		node_size = 88.0
	elif state == "future":
		node_size = 64.0

	var glow := Panel.new()
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.size = Vector2(node_size + 22.0, node_size + 22.0)
	glow.position = center - glow.size * 0.5
	glow.modulate.a = 0.0 if state == "future" else 0.34
	if state == "current":
		glow.modulate.a = 0.58
	_apply_glow_style(glow, color, int(glow.size.x * 0.5))
	theme_list.add_child(glow)

	var node := Panel.new()
	node.mouse_filter = Control.MOUSE_FILTER_PASS
	node.size = Vector2(node_size, node_size)
	node.position = center - node.size * 0.5
	_style_map_node(node, color, state)
	theme_list.add_child(node)
	var tap_start := Vector2.ZERO
	var tap_tracking := false
	node.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventScreenTouch:
			if event.pressed:
				tap_tracking = true
				tap_start = event.position
			elif tap_tracking and not map_touch_moved and tap_start.distance_to(event.position) < 18.0:
				_select_universe_map_entry(entry, center, state)
				tap_tracking = false
			else:
				tap_tracking = false
		elif event is InputEventScreenDrag and tap_tracking and tap_start.distance_to(event.position) >= 18.0:
			tap_tracking = false
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				tap_tracking = true
				tap_start = event.position
			elif tap_tracking and not map_touch_moved and tap_start.distance_to(event.position) < 18.0:
				_select_universe_map_entry(entry, center, state)
				tap_tracking = false
			else:
				tap_tracking = false
		elif event is InputEventMouseMotion and tap_tracking and tap_start.distance_to(event.position) >= 18.0:
			tap_tracking = false
	)

	var icon := Label.new()
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.size = node.size
	icon.text = String(entry["icon"])
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon.add_theme_font_size_override("font_size", 33 if state == "current" else 28)
	icon.modulate.a = 0.94 if state != "future" else 0.46
	node.add_child(icon)

	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.size = Vector2(280.0, 62.0)
	label.position = Vector2(center.x + 58.0, center.y - 30.0)
	if center.x > 330.0:
		label.position.x = center.x - 338.0
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	else:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text = String(entry["name"])
	label.add_theme_font_size_override("font_size", 23 if state == "current" else 20)
	label.add_theme_color_override("font_color", _map_label_color(color, state))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.65))
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 2)
	theme_list.add_child(label)


func _select_universe_map_entry(entry: Dictionary, center: Vector2, state: String) -> void:
	selected_map_entry_id = String(entry["id"])
	_play_map_focus_sound()
	_update_map_info_label(entry, state)
	_show_map_selection_highlight(center, _destination_color(selected_map_entry_id), state)


func _play_map_focus_sound() -> void:
	var now := Time.get_ticks_msec()
	if now - last_map_focus_sound_ms < 180:
		return
	last_map_focus_sound_ms = now
	_play_sfx("button")


func _show_map_selection_highlight(center: Vector2, color: Color, state: String) -> void:
	var size := 116.0 if state == "current" else 102.0
	var ring := Panel.new()
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ring.size = Vector2(size, size)
	ring.position = center - ring.size * 0.5
	ring.modulate.a = 0.72
	_apply_glow_style(ring, color.lightened(0.18), int(size * 0.5))
	theme_list.add_child(ring)
	theme_list.move_child(ring, theme_list.get_child_count() - 1)

	var tween := create_tween()
	tween.tween_property(ring, "scale", Vector2(1.16, 1.16), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(ring, "modulate:a", 0.0, 0.32)
	tween.finished.connect(ring.queue_free)


func _update_map_info_label(entry: Dictionary = {}, state: String = "") -> void:
	if not is_instance_valid(map_info_label):
		return
	if entry.is_empty():
		var progress_height := _map_progress_height()
		entry = _journey_stop_for_height(progress_height)
		state = "current"

	var distance_text := _format_distance(_map_entry_distance(entry))
	map_info_label.text = "%s\n%s · %s" % [String(entry["name"]), distance_text, state.to_upper()]


func _map_entry_distance(entry: Dictionary) -> float:
	if entry.has("distance"):
		return float(entry["distance"])
	return _distance_for_height(int(entry["height"]))


func _update_map_scroll_focus_feedback() -> void:
	if not theme_menu.visible or not is_instance_valid(map_scroll):
		return
	var index: int = clamp(int(round(float(map_scroll.scroll_vertical + 170) / 118.0)), 0, _universe_map_entries().size() - 1)
	if map_last_scroll_index == -1:
		map_last_scroll_index = index
		return
	if index != map_last_scroll_index:
		map_last_scroll_index = index
		_play_map_focus_sound()


func _handle_map_scroll_input(event: InputEvent) -> void:
	if not theme_menu.visible:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			map_touch_scrolling = true
			map_touch_moved = false
			map_touch_start = event.position
			map_touch_last = event.position
			map_scroll_velocity = 0.0
		else:
			map_touch_scrolling = false
	elif event is InputEventScreenDrag and map_touch_scrolling:
		if map_touch_start.distance_to(event.position) >= 12.0:
			map_touch_moved = true
		_scroll_universe_map_by(-event.relative.y)
		map_touch_last = event.position
		map_scroll_velocity = -event.velocity.y
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			map_touch_scrolling = true
			map_touch_moved = false
			map_touch_start = event.position
			map_touch_last = event.position
			map_scroll_velocity = 0.0
		else:
			map_touch_scrolling = false
	elif event is InputEventMouseMotion and map_touch_scrolling:
		if map_touch_start.distance_to(event.position) >= 12.0:
			map_touch_moved = true
		_scroll_universe_map_by(-event.relative.y)
		map_touch_last = event.position
		map_scroll_velocity = -event.relative.y * 55.0


func _update_map_touch_inertia(delta: float) -> void:
	if not theme_menu.visible or map_touch_scrolling:
		return
	if abs(map_scroll_velocity) < 8.0:
		map_scroll_velocity = 0.0
		return
	_scroll_universe_map_by(map_scroll_velocity * delta)
	map_scroll_velocity = move_toward(map_scroll_velocity, 0.0, 2600.0 * delta)


func _scroll_universe_map_by(amount: float) -> void:
	if not is_instance_valid(map_scroll):
		return
	var bar: VScrollBar = map_scroll.get_v_scroll_bar()
	var max_scroll: float = max(0.0, bar.max_value - bar.page)
	map_scroll.scroll_vertical = int(clamp(float(map_scroll.scroll_vertical) + amount, 0.0, max_scroll))


func _style_map_node(panel: Panel, color: Color, state: String) -> void:
	var style := StyleBoxFlat.new()
	var alpha := 0.92
	var border_alpha := 0.96
	if state == "future":
		alpha = 0.22
		border_alpha = 0.3
	elif state == "current":
		alpha = 1.0
	style.bg_color = Color(color.r, color.g, color.b, alpha)
	style.border_color = Color(color.r, color.g, color.b, border_alpha)
	style.set_border_width_all(3 if state == "current" else 2)
	style.set_corner_radius_all(int(panel.size.x * 0.5))
	style.shadow_color = Color(color.r, color.g, color.b, 0.36 if state == "current" else 0.18)
	style.shadow_size = 14 if state == "current" else 7
	panel.add_theme_stylebox_override("panel", style)


func _map_label_color(color: Color, state: String) -> Color:
	if state == "future":
		return Color(0.72, 0.78, 0.9, 0.58)
	if state == "current":
		return Color(1.0, 1.0, 1.0, 1.0)
	return color.lightened(0.28)


func _destination_color(id: String) -> Color:
	match id:
		"earth":
			return Color(0.18, 0.76, 1.0)
		"moon":
			return Color(0.82, 0.84, 0.88)
		"mars":
			return Color(1.0, 0.32, 0.18)
		"jupiter":
			return Color(1.0, 0.58, 0.24)
		"saturn":
			return Color(1.0, 0.76, 0.32)
		"uranus":
			return Color(0.48, 1.0, 1.0)
		"neptune":
			return Color(0.16, 0.42, 1.0)
		"pluto":
			return Color(0.74, 0.88, 1.0)
		"oort_cloud", "leaving_solar_system":
			return Color(0.9, 0.96, 1.0)
		"alpha_centauri":
			return Color(1.0, 0.84, 0.28)
		"proxima_b":
			return Color(0.78, 0.28, 0.18)
		"trappist_worlds":
			return Color(0.86, 0.58, 0.38)
		"interstellar_space":
			return Color(0.28, 0.22, 0.78)
		"orion_arm":
			return Color(0.5, 0.42, 1.0)
		"milky_way", "leaving_galaxy":
			return Color(0.82, 0.92, 1.0)
		"andromeda":
			return Color(0.5, 0.48, 1.0)
		"deep_void":
			return Color(0.14, 0.04, 0.22)
		"infinity":
			return Color(0.94, 0.82, 1.0)
	return Color(0.42, 0.9, 1.0)


func _scroll_universe_map_to_progress() -> void:
	await get_tree().process_frame
	if not is_instance_valid(map_scroll):
		return
	var entries := _universe_map_entries()
	var current_height := int(_journey_stop_for_height(_map_progress_height())["height"])
	var row_height := 118.0
	var current_index := 0
	for index in entries.size():
		var entry: Dictionary = entries[index]
		if entry.get("transition", false) != true and int(entry["height"]) == current_height:
			current_index = index
			break
	map_scroll.scroll_vertical = max(0, int(current_index * row_height - 170.0))
	map_last_scroll_index = current_index


func _theme_button_text(theme: Dictionary, unlocked: bool, selected: bool) -> String:
	var label := "%s  %d blocks" % [theme["name"], theme["unlock"]]
	if selected:
		return "%s  Selected" % label
	if unlocked:
		return label
	return label


func _select_theme(theme_id: String) -> void:
	if not _is_theme_unlocked(theme_id):
		return

	_play_sfx("button")
	selected_theme_id = theme_id
	_apply_selected_theme()
	_save_best_score()
	_rebuild_theme_buttons()


func _toggle_sound() -> void:
	_play_sfx("button")
	sound_enabled = not sound_enabled
	_update_settings_buttons()
	_save_best_score()


func _toggle_music() -> void:
	_play_sfx("button")
	music_enabled = not music_enabled
	_update_settings_buttons()
	_update_music_state()
	_save_best_score()


func _toggle_vibration() -> void:
	_play_sfx("button")
	vibration_enabled = not vibration_enabled
	_update_settings_buttons()
	_save_best_score()
	if vibration_enabled:
		_vibrate(25)


func _update_settings_buttons() -> void:
	music_toggle_button.text = "MUSIC: ON" if music_enabled else "MUSIC: OFF"
	sound_toggle_button.text = "SOUND EFFECTS: ON" if sound_enabled else "SOUND EFFECTS: OFF"
	vibration_toggle_button.text = "HAPTIC FEEDBACK: ON" if vibration_enabled else "HAPTIC FEEDBACK: OFF"
	remove_ads_button.text = "ADS REMOVED" if ads_removed else "REMOVE ADS · COMING SOON"
	remove_ads_button.disabled = true


func _update_ad_settings() -> void:
	if ad_manager and ad_manager.has_method("set_ads_removed"):
		ad_manager.set_ads_removed(ads_removed)


func _setup_audio() -> void:
	sfx_players = {
		"button": button_sfx,
		"game_over": game_over_sfx,
		"land": land_sfx,
		"perfect": perfect_sfx,
	}

	for kind in sfx_players.keys():
		var player: AudioStreamPlayer = sfx_players[kind]
		if player:
			player.volume_db = float(SFX_VOLUME_DB.get(kind, -10.0))

	if music_player:
		music_player.volume_db = -24.0
		if not music_player.finished.is_connected(_on_music_finished):
			music_player.finished.connect(_on_music_finished)


func _play_sfx(kind: String) -> void:
	if not _audio_runtime_available():
		return

	if not sound_enabled:
		return

	if not sfx_players.has(kind):
		return

	var player: AudioStreamPlayer = sfx_players[kind]
	if not player:
		return

	if not player.stream:
		return

	var original_volume := player.volume_db
	if current_mode_id == MODE_RELAX:
		match kind:
			"perfect":
				player.volume_db = original_volume - 7.0
			"land":
				player.volume_db = original_volume - 3.0
			"drop":
				player.volume_db = original_volume - 2.0

	if player.playing:
		player.stop()
	player.play()
	player.volume_db = original_volume


func _update_music_state() -> void:
	if not music_player:
		return

	if not _audio_runtime_available():
		music_player.stop()
		return

	if music_enabled and music_player.stream:
		if not music_player.playing:
			music_player.play()
	else:
		music_player.stop()


func _on_music_finished() -> void:
	if music_enabled and music_player and music_player.stream:
		music_player.play()


func _audio_runtime_available() -> bool:
	return DisplayServer.get_name() != "headless"


func _vibrate(milliseconds: int) -> void:
	if not vibration_enabled:
		return

	Input.vibrate_handheld(milliseconds)


func _load_best_score() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		best_score = int(config.get_value("scores", "best", 0))
		best_height_blocks = int(config.get_value("scores", "best_height_blocks", best_score))
		best_destination_height = int(config.get_value("scores", "best_destination_height", 0))
		best_perfect_streak = int(config.get_value("scores", "best_perfect_streak", 0))
		best_relax_height_blocks = int(config.get_value("scores", "best_relax_height_blocks", 0))
		best_relax_destination_height = int(config.get_value("scores", "best_relax_destination_height", 0))
		selected_theme_id = String(config.get_value("themes", "selected", "earth_orbit"))
		unlocked_theme_ids = Array(config.get_value("themes", "unlocked", ["earth_orbit"]))
		selected_mode_id = String(config.get_value("modes", "selected", MODE_MISSION))
		sound_enabled = config.get_value("settings", "sound_enabled", true) == true
		music_enabled = config.get_value("settings", "music_enabled", true) == true
		vibration_enabled = config.get_value("settings", "vibration_enabled", true) == true
		ads_removed = config.get_value("settings", "ads_removed", false) == true
	if not unlocked_theme_ids.has("earth_orbit"):
		unlocked_theme_ids.append("earth_orbit")
	if not _is_theme_unlocked(selected_theme_id):
		selected_theme_id = "earth_orbit"
	if selected_mode_id != MODE_RELAX:
		selected_mode_id = MODE_MISSION
	best_destination_height = max(best_destination_height, int(_journey_stop_for_height(best_height_blocks)["height"]))
	best_relax_destination_height = max(best_relax_destination_height, int(_journey_stop_for_height(best_relax_height_blocks)["height"]))


func _save_best_score() -> void:
	var config := ConfigFile.new()
	config.set_value("scores", "best", best_score)
	config.set_value("scores", "best_height_blocks", best_height_blocks)
	config.set_value("scores", "best_destination_height", best_destination_height)
	config.set_value("scores", "best_perfect_streak", best_perfect_streak)
	config.set_value("scores", "best_relax_height_blocks", best_relax_height_blocks)
	config.set_value("scores", "best_relax_destination_height", best_relax_destination_height)
	config.set_value("themes", "selected", selected_theme_id)
	config.set_value("themes", "unlocked", unlocked_theme_ids)
	config.set_value("modes", "selected", selected_mode_id)
	config.set_value("settings", "sound_enabled", sound_enabled)
	config.set_value("settings", "music_enabled", music_enabled)
	config.set_value("settings", "vibration_enabled", vibration_enabled)
	config.set_value("settings", "ads_removed", ads_removed)
	config.save(SAVE_PATH)


func _style_panels() -> void:
	_apply_panel_style(game_over_panel, Color(0.045, 0.065, 0.12, 0.94), Color(0.2, 0.95, 1.0, 0.58))
	_apply_full_screen_panel_style(theme_menu, Color(0.025, 0.03, 0.075, 0.99), Color(0.35, 0.88, 1.0, 0.28))
	_apply_panel_style(settings_panel, Color(0.045, 0.055, 0.11, 0.94), Color(0.72, 0.38, 1.0, 0.48))
	_apply_panel_style(world_unlock_popup, Color(0.96, 0.99, 1.0, 0.97), Color(0.2, 0.95, 1.0, 0.65))
	_apply_panel_style(pause_menu, Color(0.045, 0.065, 0.12, 0.94), Color(0.2, 0.95, 1.0, 0.58))
	_apply_panel_style($UI/Root/TestAdOverlay/Panel, Color(0.045, 0.065, 0.12, 0.98), Color(0.2, 0.95, 1.0, 0.62))
	_style_title_buttons()


func _apply_panel_style(panel: PanelContainer, bg_color: Color, border_color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(3)
	style.set_corner_radius_all(18)
	style.content_margin_left = 28
	style.content_margin_right = 28
	style.content_margin_top = 24
	style.content_margin_bottom = 24
	panel.add_theme_stylebox_override("panel", style)


func _apply_full_screen_panel_style(panel: PanelContainer, bg_color: Color, border_color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(2)
	style.set_corner_radius_all(0)
	style.content_margin_left = 30
	style.content_margin_right = 30
	style.content_margin_top = 54
	style.content_margin_bottom = 24
	panel.add_theme_stylebox_override("panel", style)


func _style_title_buttons() -> void:
	_apply_button_style(play_button, Color(0.08, 0.9, 1.0, 0.96), Color(0.72, 1.0, 1.0, 0.9), Color(0.03, 0.18, 0.24, 1.0), 4)
	_apply_button_style(relax_button, Color(0.05, 0.08, 0.15, 0.78), Color(0.2, 0.95, 1.0, 0.38), Color(0.82, 0.95, 1.0, 1.0), 2)
	_apply_button_style(themes_button, Color(0.05, 0.08, 0.15, 0.66), Color(0.72, 0.38, 1.0, 0.34), Color(0.9, 0.88, 1.0, 1.0), 2)
	_apply_button_style(settings_button, Color(0.05, 0.08, 0.15, 0.66), Color(0.72, 0.38, 1.0, 0.34), Color(0.9, 0.88, 1.0, 1.0), 2)


func _apply_button_style(button: Button, bg_color: Color, border_color: Color, font_color: Color, border_width: int) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = bg_color
	normal.border_color = border_color
	normal.set_border_width_all(border_width)
	normal.set_corner_radius_all(12)
	normal.shadow_color = Color(border_color.r, border_color.g, border_color.b, 0.28)
	normal.shadow_size = 10 if border_width >= 4 else 4
	normal.content_margin_top = 12
	normal.content_margin_bottom = 12
	normal.content_margin_left = 18
	normal.content_margin_right = 18

	var hover := normal.duplicate()
	hover.bg_color = bg_color.lightened(0.08)
	hover.shadow_size = normal.shadow_size + 3

	var pressed := normal.duplicate()
	pressed.bg_color = bg_color.darkened(0.08)
	pressed.shadow_size = max(2, normal.shadow_size - 3)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_color_override("font_color", font_color)
	button.add_theme_color_override("font_hover_color", font_color.lightened(0.08))
	button.add_theme_color_override("font_pressed_color", font_color.darkened(0.08))
