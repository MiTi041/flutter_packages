import 'dart:io';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

mixin class Vibrate {
  Future<bool> checkVibrate() async {
    bool? vibrate = await Vibration.hasVibrator();
    if (!vibrate) {
      return false;
    } else {
      return true;
    }
  }

  void vibrate() async {
    if (!await checkVibrate()) return;
    if (Platform.isIOS) {
      HapticFeedback.mediumImpact();
    } else {
      Vibration.vibrate(duration: 100);
    }
  }

  void vibrateLight() async {
    if (!await checkVibrate()) return;
    if (Platform.isIOS) {
      HapticFeedback.lightImpact();
    } else {
      Vibration.vibrate(duration: 50);
    }
  }

  void vibrateMedium() async {
    if (!await checkVibrate()) return;
    if (Platform.isIOS) {
      HapticFeedback.mediumImpact();
    } else {
      Vibration.vibrate(duration: 50);
    }
  }

  void vibrateHeavy() async {
    if (!await checkVibrate()) return;
    if (Platform.isIOS) {
      HapticFeedback.heavyImpact();
    } else {
      Vibration.vibrate(duration: 50);
    }
  }
}
