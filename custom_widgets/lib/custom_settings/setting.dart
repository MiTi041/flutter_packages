import 'package:custom_utils/custom_vibrate.dart';
import 'package:custom_widgets/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';

// ignore: must_be_immutable
class Setting extends StatefulWidget {
  final bool isLink;
  final String titel;
  final IconData? icon;
  final VoidCallback? click;
  final bool isSelection;
  final bool selected;
  bool noBorder;

  Setting({
    this.isLink = false,
    required this.titel,
    this.icon,
    this.click,
    this.isSelection = false,
    this.selected = false,
    this.noBorder = false,
    super.key,
  });

  @override
  SettingState createState() => SettingState();
}

class SettingState extends State<Setting> with SingleTickerProviderStateMixin, Vibrate {
  // Variables

  // Instances
  late AnimationController animationController;
  late Animation<double> opacityAnimation;

  // Standard
  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));

    // Initialize opacity animation
    opacityAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut, // Animationskurve
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose(); // Dispose the animation controller
    super.dispose();
  }

  // Functions
  void onTap() {
    // Start the animation
    animationController.forward().then((_) {
      // Reverse the animation after it completes
      animationController.reverse();
    });

    // Vibrate and trigger click
    vibrateLight();
    if (widget.click != null) widget.click!();
  }

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
          animation: opacityAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: opacityAnimation.value,
              child: Container(
                margin: const EdgeInsets.only(left: 15),
                decoration: BoxDecoration(
                  color: constants.primary,
                  border: widget.noBorder ? null : Border(bottom: BorderSide(color: constants.secondary)),
                ),
                child: Row(
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 17, color: constants.fontColor),
                      const Gap(15),
                    ],
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Row(
                          children: [
                            Text(
                              widget.titel,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                height: 1,
                                fontFamily: constants.fontFamily,
                                fontSize: constants.mediumFontSize,
                                color: constants.fontColor,
                                fontWeight: constants.medium,
                              ),
                            ),
                            const Spacer(),
                            widget.isSelection
                                ? widget.selected
                                    ? SizedBox(
                                        height: 10,
                                        width: 10,
                                        child: Image.asset('${constants.imgPath}check.png'),
                                      )
                                    : const SizedBox.shrink()
                                : widget.isLink
                                    ? Icon(CupertinoIcons.arrow_up_right, size: 15, color: constants.subFontColor)
                                    : Icon(CupertinoIcons.chevron_right, size: 15, color: constants.subFontColor),
                            const Gap(10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
