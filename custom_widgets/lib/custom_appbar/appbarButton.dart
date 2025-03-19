import 'package:custom_widgets/custom_clickAnimationWrap.dart/clickAnimationWrap.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:custom_widgets/constants.dart';

class AppbarButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final Color? color;
  final Color? fontColor;
  final Color? borderColor;

  final VoidCallback? click;
  final VoidCallback? longPress;

  const AppbarButton({
    this.text,
    this.icon,
    this.color,
    this.fontColor,
    this.borderColor,
    this.click,
    this.longPress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();
    final size = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

    return ClickAnimationWrap(
      disabled: click == null,
      onTap: () {
        if (click != null) click!();
      },
      onLongPress: () {
        if (longPress != null) longPress!();
      },
      child: Container(
        height: 30,
        constraints: const BoxConstraints(minWidth: 30),
        padding: EdgeInsets.fromLTRB(
          text != null && icon == null ? 10 : (icon != null && text != null ? 5 : 0),
          0,
          text != null ? 10 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: color ?? constants.primary,
          border: Border.all(color: borderColor ?? constants.secondary, width: 1),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) Icon(icon, size: 17, color: fontColor ?? constants.fontColor),
              if (icon != null && text != null) const Gap(5),
              if (text != null)
                Expanded(
                  child: Text(
                    text!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      height: 1,
                      fontFamily: constants.fontFamily,
                      fontSize: constants.mediumFontSize,
                      color: fontColor ?? constants.fontColor,
                      fontWeight: constants.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
