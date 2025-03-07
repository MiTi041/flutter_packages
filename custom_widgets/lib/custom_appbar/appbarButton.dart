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

  const AppbarButton({
    this.text,
    this.icon,
    this.color,
    this.fontColor,
    this.borderColor,
    this.click,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();

    return GestureDetector(
      onTap: () {
        if (click != null) click!();
      },
      child: Container(
        height: 30,
        constraints: const BoxConstraints(minWidth: 30),
        padding: EdgeInsets.fromLTRB(text != null ? 15 : 0, 0, text != null ? 15 : 0, 0),
        decoration: BoxDecoration(color: color ?? constants.primary, border: Border.all(color: borderColor ?? constants.secondary, width: 1), borderRadius: BorderRadius.circular(50)),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) Icon(icon, size: 17, color: fontColor ?? constants.fontColor),
              if (icon != null && text != null) const Gap(5),
              if (text != null)
                Text(text!, style: TextStyle(height: 1, fontFamily: constants.fontFamily, fontSize: constants.mediumFontSize, color: fontColor ?? constants.fontColor, fontWeight: constants.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
