import 'package:custom_widgets/constants.dart';
import 'package:custom_widgets/custom_appbar/appbarButton.dart';
import 'package:custom_widgets/custom_appbar/appbar.dart';
import 'package:custom_widgets/custom_frame/frame.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cupernino_bottom_sheet/flutter_cupernino_bottom_sheet.dart';

class CustomModalPopup {
  final Constants constants = Constants();
  final size = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

  void show(context, String titel, Widget widget, {bool neverScrollPhysics = false}) {
    Navigator.of(context).push(
      CupertinoBottomSheetRoute(
        args: const CupertinoBottomSheetRouteArgs(
          swipeSettings: SwipeSettings(
            canCloseBySwipe: true,
          ),
        ),
        builder: (context) {
          return Frame(
            isModalPopup: true,
            neverScrollPhysics: neverScrollPhysics,
            appbar: Appbar(isModalPopup: true, titel: titel, actions: [
              AppbarButton(
                icon: CupertinoIcons.xmark,
                fontColor: constants.subFontColor,
                click: () async {
                  Navigator.of(context).pop();
                },
              ),
            ]),
            widget: widget,
          );
        },
      ),
    );
  }
}
