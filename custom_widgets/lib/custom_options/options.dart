import 'package:custom_utils/custom_navigate.dart';
import 'package:custom_utils/custom_vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:custom_widgets/constants.dart';
import 'package:custom_widgets/custom_message/messageWidget.dart';
import 'package:custom_widgets/custom_options/option.dart';

class OptionsTarget {}

class Options with Navigate {
  static final Options singleton = Options._internal();

  factory Options() {
    return singleton;
  }

  Options._internal();

  OverlayEntry? overlayEntry;
  final Constants constants = Constants();
  final size = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

  void closeOptions() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  void showOptions(BuildContext context, {required List<Option> items}) {
    FocusScope.of(context).unfocus();

    Vibrate().vibrateLight();

    overlayEntry = OverlayEntry(
      builder: (context) => MessageWidget(
        titel: "Optionen",
        text: "Wähle eine Option",
        icon: CupertinoIcons.gear_alt_fill,
        buttonText: "Abbrechen",
        isTooltip: false,
        fontColor: constants.red,
        items: items,
        click: () {
          closeOptions();
        },
        close: () {
          closeOptions();
        },
        outerTap: () {
          closeOptions();
        },
      ),
    );

    Overlay.of(context).insert(overlayEntry!);
  }
}
