import 'package:vibration/vibration.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

mixin class Vibrate {
  Future<bool> checkVibrate() async {
    bool? vibrate = await Vibration.hasVibrator();
    if (!vibrate) {
      return false;
    } else {
      return true;
    }
  }

  void vibrateSuccess() async {
    if (!await checkVibrate()) return;
    await Haptics.vibrate(HapticsType.success);
  }

  vibrateRigid() async {
    if (!await checkVibrate()) return;
    await Haptics.vibrate(HapticsType.rigid);
  }

  void vibrateLight() async {
    if (!await checkVibrate()) return;
    await Haptics.vibrate(HapticsType.light);
  }

  void vibrateMedium() async {
    if (!await checkVibrate()) return;
    await Haptics.vibrate(HapticsType.medium);
  }

  void vibrateHeavy() async {
    if (!await checkVibrate()) return;
    await Haptics.vibrate(HapticsType.heavy);
  }
}
