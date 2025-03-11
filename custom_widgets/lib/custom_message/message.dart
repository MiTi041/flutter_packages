import 'dart:async';
import 'package:custom_widgets/custom_message/messageWidget.dart';
import 'package:flutter/material.dart';

class Message {
  // message
  OverlayEntry? message;

  Future<bool> showMessage(
    context, {
    IconData? icon,
    Image? image,
    String? titel,
    String? text,
    String buttonText = "Verstanden",
    Color? fontColor,
    String? closeButton,
    Color? closeButtonColor,
    bool isTooltip = false,
    bool outerTapReturnsTrue = false,
    Color? iconColor,
    bool outerTapDoesNotClose = false,
  }) {
    Completer<bool> completer = Completer<bool>();

    FocusScope.of(context).unfocus();

    message = OverlayEntry(
      builder: (context) => MessageWidget(
        titel: titel,
        text: text,
        icon: icon,
        image: image,
        buttonText: buttonText,
        isTooltip: isTooltip,
        fontColor: fontColor,
        closeButton: closeButton,
        closeButtonColor: closeButtonColor,
        iconColor: iconColor,
        click: () {
          completer.complete(true);
          closeMessage();
        },
        close: () {
          completer.complete(false);
          closeMessage();
        },
        outerTap: outerTapDoesNotClose
            ? null
            : () {
                completer.complete(outerTapReturnsTrue);
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
