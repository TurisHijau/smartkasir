import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

enum TutorialPhase {
  addProduct,
  scanProduct,
  checkout,
  advancedExploration,
  completed,
}

class TutorialHelper {
  static const String _phaseKey = 'tutorial_phase_state';

  static Future<TutorialPhase> getTutorialPhase() async {
    final prefs = await SharedPreferences.getInstance();
    final phaseIndex = prefs.getInt(_phaseKey) ?? 0;
    if (phaseIndex >= TutorialPhase.values.length) {
      return TutorialPhase.completed;
    }
    return TutorialPhase.values[phaseIndex];
  }

  static Future<void> advanceTutorialPhase(TutorialPhase currentPhase) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPhaseIndex = prefs.getInt(_phaseKey) ?? 0;

    if (savedPhaseIndex == currentPhase.index) {
      final nextPhaseIndex = savedPhaseIndex + 1;
      await prefs.setInt(_phaseKey, nextPhaseIndex);
    }
  }

  static Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_phaseKey);
    await prefs.remove('tutorial_scanner_view');
    await prefs.remove('tutorial_settings_view');
    await prefs.remove('tutorial_list_produk');
  }

  static void showTutorial({
    required BuildContext context,
    required List<TargetFocus> targets,
    VoidCallback? onFinish,
    Function(TargetFocus)? onClickTarget,
  }) async {
    if (targets.isEmpty) return;
    if (!context.mounted) return;

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      textSkip: "LEWATI",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        if (onFinish != null) onFinish();
      },
      onClickTarget: (target) {
        if (onClickTarget != null) {
          onClickTarget(target);
        }
      },
      onClickTargetWithTapPosition: (target, tapDetails) {},
      onClickOverlay: (target) {},
      onSkip: () {
        if (onFinish != null) onFinish();
        return true;
      },
    ).show(context: context);
  }
}
