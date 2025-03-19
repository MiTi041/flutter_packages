import 'package:custom_widgets/constants.dart';
import 'package:custom_widgets/custom_clickAnimationWrap.dart/clickAnimationWrap.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Option extends StatelessWidget {
  final String text;
  final IconData? icon;

  final VoidCallback? click;

  const Option({required this.text, this.icon, required this.click, super.key});

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();

    return ClickAnimationWrap(
      onTap: () {
        click!();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: constants.background, border: Border(top: BorderSide(color: constants.primary, width: 0.5), bottom: BorderSide(color: constants.primary, width: 0.5))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: TextStyle(height: 1, fontFamily: constants.fontFamily, fontSize: constants.regularFontSize, color: constants.fontColor, fontWeight: constants.medium)),
            if (icon != null) ...[
              const Gap(5),
              Center(
                child: Icon(
                  icon,
                  size: 15,
                  color: constants.fontColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
