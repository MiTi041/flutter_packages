import 'package:custom_widgets/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';

class Line extends StatelessWidget {
  final double marginTopBottom;
  final Color? color;

  const Line({
    super.key,
    this.marginTopBottom = 15,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final size = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    Constants constants = Constants();

    return Column(
      children: [
        Gap(marginTopBottom),
        SizedBox(
          width: double.infinity,
          child: Center(
            child: Container(
              width: size.width - 50,
              height: 1,
              color: color ?? constants.secondary,
            ),
          ),
        ),
        Gap(marginTopBottom),
      ],
    );
  }
}
