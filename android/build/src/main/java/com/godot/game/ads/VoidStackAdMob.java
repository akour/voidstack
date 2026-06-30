package com.godot.game.ads;

import android.app.Activity;
import android.util.Log;

import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.initialization.InitializationStatus;
import com.google.android.gms.ads.interstitial.InterstitialAd;
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback;
import com.google.android.gms.ads.rewarded.RewardedAd;
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback;

import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;
import org.godotengine.godot.plugin.UsedByGodot;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class VoidStackAdMob extends GodotPlugin {
	private static final String TAG = "VoidStackAdMob";

	private RewardedAd rewardedAd;
	private InterstitialAd interstitialAd;
	private boolean initialized = false;
	private boolean rewardedEarned = false;

	public VoidStackAdMob(Godot godot) {
		super(godot);
	}

	@Override
	public String getPluginName() {
		return "VoidStackAdMob";
	}

	@Override
	public void onGodotSetupCompleted() {
		Log.d(TAG, "ADMOB FLOW: Godot setup completed for singleton " + getPluginName());
	}

	@Override
	public List<String> getPluginMethods() {
		return Arrays.asList(
			"initialize",
			"loadRewarded",
			"loadRewardedAd",
			"isRewardedReady",
			"showRewarded",
			"showRewardedAd",
			"loadInterstitial",
			"loadInterstitialAd",
			"isInterstitialReady",
			"showInterstitial",
			"showInterstitialAd"
		);
	}

	@Override
	public Set<SignalInfo> getPluginSignals() {
		Set<SignalInfo> signals = new HashSet<>();
		signals.add(new SignalInfo("admob_initialized", Boolean.class));
		signals.add(new SignalInfo("rewarded_ad_loaded"));
		signals.add(new SignalInfo("rewarded_ad_load_failed", String.class));
		signals.add(new SignalInfo("rewarded_ad_shown"));
		signals.add(new SignalInfo("rewarded_ad_completed"));
		signals.add(new SignalInfo("rewarded_ad_failed"));
		signals.add(new SignalInfo("rewarded_ad_closed", Boolean.class));
		signals.add(new SignalInfo("interstitial_ad_loaded"));
		signals.add(new SignalInfo("interstitial_ad_load_failed"));
		signals.add(new SignalInfo("interstitial_ad_closed"));
		signals.add(new SignalInfo("interstitial_ad_failed"));
		return signals;
	}

	@UsedByGodot
	public void initialize(String appId) {
		Activity activity = getActivity();
		Log.d(TAG, "ADMOB FLOW: SDK init start app_id=" + appId + " activity_present=" + (activity != null));
		if (activity == null) {
			Log.w(TAG, "ADMOB FLOW: SDK init failure message=activity_missing");
			emitSignal("admob_initialized", false);
			return;
		}

		runOnUiThread(() -> {
			try {
				MobileAds.initialize(activity, (InitializationStatus status) -> {
					initialized = true;
					Log.d(TAG, "ADMOB FLOW: SDK initialized status=" + status);
					emitSignal("admob_initialized", true);
				});
			} catch (Exception exception) {
				Log.e(TAG, "ADMOB FLOW: SDK init failure message=" + exception.getMessage(), exception);
				initialized = false;
				emitSignal("admob_initialized", false);
			}
		});
	}

	@UsedByGodot
	public void loadRewarded(String adUnitId) {
		Activity activity = getActivity();
		Log.d(TAG, "ADMOB FLOW: rewarded load requested ad_unit_id=" + adUnitId + " initialized=" + initialized + " activity_present=" + (activity != null));
		if (!initialized || activity == null || adUnitId == null || adUnitId.isEmpty()) {
			String errorText = "code=load_skipped message=plugin not initialized, activity missing, or ad unit missing";
			Log.w(TAG, "ADMOB FLOW: rewarded failed with error " + errorText);
			emitSignal("rewarded_ad_load_failed", errorText);
			return;
		}

		runOnUiThread(() -> RewardedAd.load(
			activity,
			adUnitId,
			new AdRequest.Builder().build(),
			new RewardedAdLoadCallback() {
				@Override
				public void onAdLoaded(RewardedAd ad) {
					Log.d(TAG, "ADMOB FLOW: rewarded loaded");
					rewardedAd = ad;
					emitSignal("rewarded_ad_loaded");
				}

				@Override
				public void onAdFailedToLoad(LoadAdError error) {
					String errorText = formatLoadAdError(error);
					Log.w(TAG, "ADMOB FLOW: rewarded failed with error " + errorText);
					rewardedAd = null;
					emitSignal("rewarded_ad_load_failed", errorText);
				}
			}
		));
	}

	@UsedByGodot
	public void loadRewardedAd(String adUnitId) {
		loadRewarded(adUnitId);
	}

	@UsedByGodot
	public Boolean isRewardedReady() {
		return rewardedAd != null;
	}

	@UsedByGodot
	public Boolean showRewarded() {
		Activity activity = getActivity();
		Log.d(TAG, "ADMOB FLOW: rewarded show requested ready=" + (rewardedAd != null) + " activity_present=" + (activity != null));
		if (activity == null || rewardedAd == null) {
			Log.w(TAG, "ADMOB FLOW: rewarded failed with error code=show_skipped message=activity missing or rewarded ad not loaded");
			emitSignal("rewarded_ad_failed");
			return false;
		}

		runOnUiThread(() -> {
			RewardedAd adToShow = rewardedAd;
			rewardedAd = null;
			rewardedEarned = false;
			adToShow.setFullScreenContentCallback(new FullScreenContentCallback() {
				@Override
				public void onAdShowedFullScreenContent() {
					Log.d(TAG, "ADMOB FLOW: rewarded shown");
					emitSignal("rewarded_ad_shown");
				}

				@Override
				public void onAdDismissedFullScreenContent() {
					Log.d(TAG, "ADMOB FLOW: rewarded closed reward_earned=" + rewardedEarned);
					if (rewardedEarned) {
						emitSignal("rewarded_ad_completed");
					} else {
						emitSignal("rewarded_ad_failed");
					}
					emitSignal("rewarded_ad_closed", rewardedEarned);
				}

				@Override
				public void onAdFailedToShowFullScreenContent(AdError error) {
					Log.w(TAG, "ADMOB FLOW: rewarded failed with error " + formatAdError(error));
					rewardedEarned = false;
					emitSignal("rewarded_ad_failed");
					emitSignal("rewarded_ad_closed", false);
				}
			});
			adToShow.show(activity, rewardItem -> {
				Log.d(TAG, "ADMOB FLOW: reward earned type=" + rewardItem.getType() + " amount=" + rewardItem.getAmount());
				rewardedEarned = true;
			});
		});
		return true;
	}

	@UsedByGodot
	public Boolean showRewardedAd() {
		return showRewarded();
	}

	@UsedByGodot
	public void loadInterstitial(String adUnitId) {
		Activity activity = getActivity();
		if (!initialized || activity == null || adUnitId == null || adUnitId.isEmpty()) {
			emitSignal("interstitial_ad_load_failed");
			return;
		}

		runOnUiThread(() -> InterstitialAd.load(
			activity,
			adUnitId,
			new AdRequest.Builder().build(),
			new InterstitialAdLoadCallback() {
				@Override
				public void onAdLoaded(InterstitialAd ad) {
					interstitialAd = ad;
					emitSignal("interstitial_ad_loaded");
				}

				@Override
				public void onAdFailedToLoad(LoadAdError error) {
					Log.w(TAG, "Interstitial ad failed to load: " + error);
					interstitialAd = null;
					emitSignal("interstitial_ad_load_failed");
				}
			}
		));
	}

	@UsedByGodot
	public void loadInterstitialAd(String adUnitId) {
		loadInterstitial(adUnitId);
	}

	@UsedByGodot
	public Boolean isInterstitialReady() {
		return interstitialAd != null;
	}

	@UsedByGodot
	public Boolean showInterstitial() {
		Activity activity = getActivity();
		if (activity == null || interstitialAd == null) {
			emitSignal("interstitial_ad_failed");
			return false;
		}

		runOnUiThread(() -> {
			InterstitialAd adToShow = interstitialAd;
			interstitialAd = null;
			adToShow.setFullScreenContentCallback(new FullScreenContentCallback() {
				@Override
				public void onAdDismissedFullScreenContent() {
					emitSignal("interstitial_ad_closed");
				}

				@Override
				public void onAdFailedToShowFullScreenContent(AdError error) {
					Log.w(TAG, "Interstitial ad failed to show: " + error);
					emitSignal("interstitial_ad_failed");
				}
			});
			adToShow.show(activity);
		});
		return true;
	}

	@UsedByGodot
	public Boolean showInterstitialAd() {
		return showInterstitial();
	}

	private String formatLoadAdError(LoadAdError error) {
		if (error == null) {
			return "code=unknown message=LoadAdError null";
		}
		String responseInfo = error.getResponseInfo() == null ? "null" : error.getResponseInfo().toString();
		return "code=" + error.getCode()
			+ " domain=" + error.getDomain()
			+ " message=" + error.getMessage()
			+ " response_info=" + responseInfo;
	}

	private String formatAdError(AdError error) {
		if (error == null) {
			return "code=unknown message=AdError null";
		}
		return "code=" + error.getCode()
			+ " domain=" + error.getDomain()
			+ " message=" + error.getMessage();
	}
}
