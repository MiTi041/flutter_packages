import 'package:custom_widgets/constants.dart';
import 'package:custom_widgets/custom_settings/setting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SettingWrap extends StatelessWidget {
  final String? titel;
  final List<Setting> items;
  final VoidCallback? click;

  const SettingWrap({
    this.titel,
    required this.items,
    this.click,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();

    if (items.isNotEmpty) {
      items.last.noBorder = true;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titel != null) ...[
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: Text(
              titel!,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                height: 1,
                fontFamily: constants.fontFamily,
                fontSize: constants.regularFontSize,
                color: constants.subFontColor,
                fontWeight: constants.medium,
              ),
            ),
          ),
          const Gap(7),
        ],
        Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: constants.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) items[i],
            ],
          ),
        ),
      ],
    );
  }
}
