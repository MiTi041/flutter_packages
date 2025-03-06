import 'snackBarStatus.dart';
import 'package:flutter/material.dart';
import 'package:custom_widgets/custom_button/button.dart';
import 'snackbar.dart';

class SnackBarProvider with ChangeNotifier {
  static final SnackBarProvider singleton = SnackBarProvider._internal();

  factory SnackBarProvider() {
    return singleton;
  }

  SnackBarProvider._internal();

  OverlayEntry? overlayEntry;

  void showSnackBar(BuildContext context, {required String text, status = SnackBarStatus.normal, Button? button}) {
    slideUpSnackBar();

    final OverlayState overlayState = Overlay.of(context);

    final CustomSnackbar snackBar = CustomSnackbar(slideUpSnackBar: slideUpSnackBar, text: text, status: status, button: button);

    overlayEntry = createOverlayEntry(context, snackBar);
    overlayState.insert(overlayEntry!);
  }

  void slideUpSnackBar() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
  }

  OverlayEntry createOverlayEntry(BuildContext context, CustomSnackbar snackBar) {
    return OverlayEntry(builder: (context) => snackBar);
  }
}
