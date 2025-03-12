import 'package:custom_widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:gap/gap.dart';
import 'package:custom_widgets/custom_button/button.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? text;
  final Widget? illustration;
  final List<Button> button;

  const EmptyState({
    required this.title,
    this.text,
    this.illustration,
    this.button = const [],
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();
    final size = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

    return FadeIn(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (illustration != null) Column(children: [Container(width: double.infinity, constraints: const BoxConstraints(maxHeight: 100), child: illustration!), const Gap(15)]),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1,
                fontFamily: constants.fontFamily,
                fontSize: constants.semibigFontSize,
                color: text == null ? constants.subFontColor : constants.fontColor,
                fontWeight: constants.semi,
              ),
            ),
            if (text != null) ...[
              const Gap(5),
              Text(
                text!,
                textAlign: TextAlign.center,
                style: TextStyle(height: 1, fontFamily: constants.fontFamily, fontSize: constants.regularFontSize, color: constants.subFontColor, fontWeight: constants.medium),
              ),
            ],
            if (button.isNotEmpty)
              Column(
                children: [
                  const Gap(15),
                  Wrap(
                    runSpacing: 10,
                    children: button,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
