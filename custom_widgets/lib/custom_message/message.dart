import 'dart:async';
import 'package:custom_widgets/custom_message/messageWidget.dart';
import 'package:flutter/material.dart';

class Message {
  // message
  OverlayEntry? message;

  Future<bool> showMessage(context, {Image? icon, String? titel, String? text, String buttonText = "Verstanden", String? textIcon, Color? fontColor, String? closeButton, isTooltip = false}) {
    Completer<bool> completer = Completer<bool>();

    FocusScope.of(context).unfocus();

    message = OverlayEntry(
      builder:
          (context) => MessageWidget(
            titel: titel,
            text: text,
            icon: icon,
            buttonText: buttonText,
            textIcon: textIcon,
            isTooltip: isTooltip,
            fontColor: fontColor,
            closeButton: closeButton,
            click: () {
              completer.complete(true);
              closeMessage();
            },
            close: () {
              completer.complete(false);
              closeMessage();
            },
          ),
    );
    Overlay.of(context).insert(message!);

    return completer.future;
  }

  void closeMessage() {
    message?.remove();
    message = null;
  }
}
