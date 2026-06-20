extends Node
class_name AdManager

var completed_runs := 0


func can_show_rewarded_continue() -> bool:
	return true


func show_rewarded_continue() -> bool:
	print("Fake rewarded continue ad shown")
	return true


func show_interstitial_if_needed() -> void:
	completed_runs += 1

	# No interstitials during the first few attempts, then only every 4th game over.
	if completed_runs >= 5 and completed_runs % 4 == 0:
		print("Fake interstitial ad shown")
