extends Node
class_name AdManager

const TEST_AD_MODE := false
const USE_ADMOB_SAMPLE_ADS := true
const ADMOB_APP_ID := "ca-app-pub-6110832134357980~8349650921"
const REWARDED_CONTINUE_AD_UNIT_ID := "ca-app-pub-6110832134357980/1250879784"
const INTERSTITIAL_GAME_OVER_AD_UNIT_ID := "ca-app-pub-6110832134357980/8937798111"
const SAMPLE_REWARDED_AD_UNIT_ID := "ca-app-pub-3940256099942544/5224354917"
const SAMPLE_INTERSTITIAL_AD_UNIT_ID := "ca-app-pub-3940256099942544/1033173712"
const ADMOB_SINGLETON_NAME := "VoidStackAdMob"

signal rewarded_continue_completed
signal rewarded_continue_failed
signal rewarded_ad_shown
signal interstitial_finished
signal rewarded_ad_state_changed
signal android_back_pressed

var completed_runs := 0
var ads_removed := false
var admob
var real_admob_available := false
var real_admob_initialized := false
var pending_rewarded_continue := false
var rewarded_ad_loading := false
var rewarded_ad_ready := false
var rewarded_ad_load_failed := false
var rewarded_ad_last_error := ""
var interstitial_ad_ready := false


func _ready() -> void:
	print("ADMOB FLOW: config TEST_AD_MODE=", TEST_AD_MODE, " USE_ADMOB_SAMPLE_ADS=", USE_ADMOB_SAMPLE_ADS, " ads_removed=", ads_removed)
	if not TEST_AD_MODE:
		print("ADMOB FLOW: SDK init start")
		_setup_real_admob()


func set_ads_removed(value: bool) -> void:
	ads_removed = value
	print("ADMOB FLOW: ads_removed updated=", ads_removed)


func is_test_ad_mode() -> bool:
	return TEST_AD_MODE


func is_using_admob_sample_ads() -> bool:
	return USE_ADMOB_SAMPLE_ADS


func is_rewarded_ad_ready() -> bool:
	if TEST_AD_MODE:
		return true
	return real_admob_available and _is_rewarded_ready()


func is_rewarded_ad_loading() -> bool:
	return rewarded_ad_loading


func did_rewarded_ad_load_fail() -> bool:
	return rewarded_ad_load_failed


func rewarded_ad_error() -> String:
	return rewarded_ad_last_error


func rewarded_ad_unit_id() -> String:
	return _rewarded_ad_unit_id()


func rewarded_debug_state() -> Dictionary:
	return {
		"test_ad_mode": TEST_AD_MODE,
		"use_admob_sample_ads": USE_ADMOB_SAMPLE_ADS,
		"ads_removed": ads_removed,
		"rewarded_ad_unit_id": _rewarded_ad_unit_id(),
		"real_admob_available": real_admob_available,
		"real_admob_initialized": real_admob_initialized,
		"rewarded_ready": is_rewarded_ad_ready(),
		"rewarded_loading": rewarded_ad_loading,
		"rewarded_load_failed": rewarded_ad_load_failed,
		"rewarded_error": rewarded_ad_last_error,
	}


func can_show_rewarded_continue() -> bool:
	if ads_removed:
		return false
	if TEST_AD_MODE:
		return true
	return is_rewarded_ad_ready()


func show_rewarded_continue() -> bool:
	if ads_removed:
		return false
	if TEST_AD_MODE:
		print("Test rewarded ad requested")
		return true
	if not real_admob_available:
		print("ADMOB FLOW: rewarded unavailable: plugin not ready")
		rewarded_ad_last_error = "Plugin not ready"
		emit_signal("rewarded_continue_failed")
		return false
	if not _is_rewarded_ready():
		print("ADMOB FLOW: rewarded unavailable: ad not loaded")
		_load_rewarded_ad()
		emit_signal("rewarded_continue_failed")
		return false

	pending_rewarded_continue = true
	print("ADMOB FLOW: rewarded show requested ready=", _is_rewarded_ready())
	rewarded_ad_ready = false
	_call_admob("showRewardedAd")
	return true


func show_interstitial_if_needed() -> bool:
	if ads_removed:
		return false

	completed_runs += 1

	# No interstitials during the first few attempts, then only every 4th game over.
	if completed_runs >= 5 and completed_runs % 4 == 0:
		if TEST_AD_MODE:
			print("Test interstitial ad requested")
			return true
		if real_admob_available and _is_interstitial_ready():
			interstitial_ad_ready = false
			_call_admob("showInterstitial")
		else:
			print("AdMob interstitial unavailable: ad not loaded")
			_load_interstitial_ad()
		return true

	return false


func _setup_real_admob() -> void:
	if not Engine.has_singleton(ADMOB_SINGLETON_NAME):
		print("ADMOB FLOW: SDK init failure message=AdMob plugin singleton not found: ", ADMOB_SINGLETON_NAME)
		rewarded_ad_load_failed = true
		rewarded_ad_last_error = "AdMob plugin singleton not found"
		emit_signal("rewarded_ad_state_changed")
		return

	admob = Engine.get_singleton(ADMOB_SINGLETON_NAME)
	print("ADMOB FLOW: plugin singleton found: ", ADMOB_SINGLETON_NAME)
	_connect_admob_signal("admob_initialized", _on_admob_initialized)
	_connect_admob_signal("rewarded_ad_loaded", _on_rewarded_ad_loaded)
	_connect_admob_signal("rewarded_ad_load_failed", _on_rewarded_ad_load_failed)
	_connect_admob_signal("rewarded_ad_shown", _on_rewarded_ad_shown)
	_connect_admob_signal("rewarded_ad_completed", _on_rewarded_ad_completed)
	_connect_admob_signal("rewarded_ad_failed", _on_rewarded_ad_failed)
	_connect_admob_signal("interstitial_ad_loaded", _on_interstitial_ad_loaded)
	_connect_admob_signal("interstitial_ad_load_failed", _on_interstitial_ad_load_failed)
	_connect_admob_signal("interstitial_ad_closed", _on_interstitial_ad_closed)
	_connect_admob_signal("interstitial_ad_failed", _on_interstitial_ad_failed)
	_connect_admob_signal("android_back_pressed", _on_android_back_pressed)
	real_admob_available = true
	print("ADMOB FLOW: SDK initialize requested app_id=", ADMOB_APP_ID)
	_call_admob("initialize", [ADMOB_APP_ID])


func _connect_admob_signal(signal_name: String, method: Callable) -> void:
	if admob and admob.has_signal(signal_name) and not admob.is_connected(signal_name, method):
		admob.connect(signal_name, method)


func _call_admob(method_name: String, args: Array = []) -> Variant:
	if not admob:
		return null
	return admob.callv(method_name, args)


func _is_rewarded_ready() -> bool:
	return rewarded_ad_ready


func _is_interstitial_ready() -> bool:
	return interstitial_ad_ready


func _load_rewarded_ad() -> void:
	if real_admob_available and not ads_removed:
		rewarded_ad_loading = true
		rewarded_ad_ready = false
		rewarded_ad_load_failed = false
		rewarded_ad_last_error = ""
		print(
			"ADMOB FLOW: rewarded load requested",
			" sample_ads=", USE_ADMOB_SAMPLE_ADS,
			" ad_unit_id=", _rewarded_ad_unit_id()
		)
		emit_signal("rewarded_ad_state_changed")
		_call_admob("loadRewardedAd", [_rewarded_ad_unit_id()])
	else:
		print(
			"ADMOB FLOW: rewarded load not requested",
			" real_admob_available=", real_admob_available,
			" ads_removed=", ads_removed,
			" ad_unit_id=", _rewarded_ad_unit_id()
		)


func _load_interstitial_ad() -> void:
	if real_admob_available and not ads_removed:
		interstitial_ad_ready = false
		_call_admob("loadInterstitialAd", [_interstitial_ad_unit_id()])


func _rewarded_ad_unit_id() -> String:
	if USE_ADMOB_SAMPLE_ADS:
		return SAMPLE_REWARDED_AD_UNIT_ID
	return REWARDED_CONTINUE_AD_UNIT_ID


func _interstitial_ad_unit_id() -> String:
	if USE_ADMOB_SAMPLE_ADS:
		return SAMPLE_INTERSTITIAL_AD_UNIT_ID
	return INTERSTITIAL_GAME_OVER_AD_UNIT_ID


func _on_admob_initialized(success: bool) -> void:
	real_admob_initialized = success
	print("ADMOB FLOW: SDK initialized success=", success)
	if not success:
		print("ADMOB FLOW: SDK init failure message=AdMob initialization returned false")
		return
	_load_rewarded_ad()
	_load_interstitial_ad()


func _on_rewarded_ad_loaded() -> void:
	rewarded_ad_loading = false
	rewarded_ad_ready = true
	rewarded_ad_load_failed = false
	rewarded_ad_last_error = ""
	print("ADMOB FLOW: rewarded loaded ready=", _is_rewarded_ready())
	emit_signal("rewarded_ad_state_changed")


func _on_rewarded_ad_load_failed(error_message: String = "") -> void:
	rewarded_ad_loading = false
	rewarded_ad_ready = false
	rewarded_ad_load_failed = true
	rewarded_ad_last_error = error_message if not error_message.is_empty() else "Load failed"
	print("ADMOB FLOW: rewarded failed with error code/message: ", rewarded_ad_last_error)
	emit_signal("rewarded_ad_state_changed")


func _on_rewarded_ad_shown() -> void:
	emit_signal("rewarded_ad_shown")


func _on_rewarded_ad_completed() -> void:
	print("ADMOB FLOW: reward earned")
	if pending_rewarded_continue:
		pending_rewarded_continue = false
		emit_signal("rewarded_continue_completed")
	_load_rewarded_ad()


func _on_rewarded_ad_failed() -> void:
	print("ADMOB FLOW: rewarded closed")
	if pending_rewarded_continue:
		pending_rewarded_continue = false
		emit_signal("rewarded_continue_failed")
	_load_rewarded_ad()


func _on_interstitial_ad_loaded() -> void:
	interstitial_ad_ready = true
	print("AdMob interstitial loaded")


func _on_interstitial_ad_load_failed() -> void:
	interstitial_ad_ready = false
	print("AdMob interstitial failed to load")


func _on_interstitial_ad_closed() -> void:
	interstitial_ad_ready = false
	emit_signal("interstitial_finished")
	_load_interstitial_ad()


func _on_interstitial_ad_failed() -> void:
	interstitial_ad_ready = false
	emit_signal("interstitial_finished")
	_load_interstitial_ad()


func _on_android_back_pressed() -> void:
	emit_signal("android_back_pressed")
