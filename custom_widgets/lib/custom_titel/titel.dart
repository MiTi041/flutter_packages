import 'package:custom_widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Titel extends StatelessWidget {
  final String text;
  final int? count;

  const Titel({required this.text, this.count, super.key});

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();
    final size = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(text, style: TextStyle(height: 1, fontFamily: constants.fontFamily, fontSize: constants.mediumFontSize, color: constants.fontColor, fontWeight: constants.medium)),
        if (count != null) ...[
          const Gap(5),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
            decoration: BoxDecoration(color: constants.primary, borderRadius: BorderRadius.circular(6)),
            child: Text(count.toString(), style: TextStyle(height: 1, fontFamily: constants.fontFamily, fontSize: constants.regularFontSize, color: constants.fontColor, fontWeight: constants.medium)),
          ),
        ],
      ],
    );
  }
}
