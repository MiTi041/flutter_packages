import 'package:flutter/material.dart';
import 'package:custom_widgets/custom_appbar/appbar.dart';
import 'package:custom_widgets/custom_frame/frame.dart';
import 'package:custom_widgets/constants.dart';
import 'package:flutter/cupertino.dart';

class CustomModalPopup {
  void show(context, String titel, Widget widget, {bool neverScrollPhysics = false}) {
    final Constants constants = Constants();

    showModalBottomSheet(
      constraints: BoxConstraints(minHeight: 200, maxHeight: (constants.size.height * 0.85) - MediaQuery.of(context).viewInsets.bottom),
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      backgroundColor: constants.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: GestureDetector(
            onTap: () {
              final currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                currentFocus.focusedChild?.unfocus();
              }
            },
            behavior: HitTestBehavior.opaque,
            child: CupertinoTheme(
              data: const CupertinoThemeData(brightness: Brightness.dark),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    top: -10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Container(height: 5, width: 40, decoration: BoxDecoration(color: constants.fontColor, borderRadius: BorderRadius.circular(50)))],
                    ),
                  ),
                  ClipRRect(
                    clipBehavior: Clip.hardEdge,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                    child: Stack(
                      children: [
                        Frame(
                          isModalPopup: true,
                          neverScrollPhysics: neverScrollPhysics,
                          shrinkWrap: true,
                          appbar: Appbar(isModalPopup: true, titel: titel, actions: const []),
                          widget: widget,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
