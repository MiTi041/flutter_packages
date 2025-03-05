import 'dart:async';
import 'package:custom_widgets/custom_snackbar/snackBarStatus.dart';
import 'package:flutter/material.dart';
import 'package:custom_widgets/custom_button/button.dart';
import 'package:custom_widgets/custom_snackBar/snackbar.dart';

class SnackBarProvider with ChangeNotifier {
  static final SnackBarProvider singleton = SnackBarProvider._internal();

  factory SnackBarProvider() {
    return singleton;
  }

  SnackBarProvider._internal();

  OverlayEntry? overlayEntry;
  bool isSliding = false;
  Timer? timer;

  void showSnackBar(BuildContext context, {required String text, status = SnackBarStatus.normal, Button? button}) {
    closeSnackBar();

    final OverlayState overlayState = Overlay.of(context);

    final CustomSnackbar snackBar = CustomSnackbar(text: text, status: status, button: button);

    overlayEntry = createOverlayEntry(context, snackBar);
    overlayState.insert(overlayEntry!);

    timer = Timer(const Duration(milliseconds: 50), () {
      if (overlayEntry != null) {
        isSliding = true;
        notifyListeners();
      }
    });

    // Schließt den Snackbar nach 3 Sekunden
    timer = Timer(const Duration(seconds: 3), () {
      slideUpSnackBar();
    });
  }

  void slideUpSnackBar() {
    if (overlayEntry == null) return; // OverlayEntry nicht vorhanden

    isSliding = false;
    notifyListeners();
    Timer(const Duration(milliseconds: 300), () {
      closeSnackBar();
    });
  }

  void closeSnackBar() {
    timer?.cancel();
    timer = null;
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
  }

  OverlayEntry createOverlayEntry(BuildContext context, CustomSnackbar snackBar) {
    return OverlayEntry(builder: (context) => snackBar);
  }
}
