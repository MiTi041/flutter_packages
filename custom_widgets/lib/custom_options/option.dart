import 'package:custom_widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Option extends StatelessWidget {
  final String text;
  final String? icon;
  final bool isIcon;

  final VoidCallback? click;

  const Option({
    required this.text,
    this.icon,
    required this.click,
    this.isIcon = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();

    return GestureDetector(
      onTap: () {
        click!();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: constants.background,
          border: Border(
            top: BorderSide(color: constants.primary, width: 0.5),
            bottom: BorderSide(color: constants.primary, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontFamily: constants.fontFamily,
                fontSize: constants.regularFontSize,
                color: constants.fontColor,
                fontWeight: constants.medium,
              ),
            ),
            if (icon != null) ...[
              const Gap(5),
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: constants.fontColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: isIcon
                      ? SizedBox(
                          height: 12,
                          width: 12,
                          child: Image.asset('${constants.imgPath}$icon'),
                        )
                      : Text(
                          " $icon",
                          textAlign: TextAlign.center,
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
