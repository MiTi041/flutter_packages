import 'package:gap/gap.dart';
import 'package:custom_utils/custom_vibrate.dart';
import 'package:custom_widgets/constants.dart';
import 'package:flutter/cupertino.dart';

class Button extends StatefulWidget with Vibrate {
  final Color? color;
  final String text;
  final bool loader;
  final bool minWidth;
  final BorderRadius? borderRadius;
  final Border? border;
  final Color? fontColor;
  final bool deactivated;
  final String? textIcon;
  final Icon? icon;
  final EdgeInsets? padding;
  final bool spaceBetweenTextAndIcon;
  final Constants? constants;

  final VoidCallback? click;

  const Button({
    required this.text,
    this.color,
    this.loader = false,
    this.deactivated = false,
    this.minWidth = false,
    this.borderRadius,
    this.border,
    this.fontColor,
    this.click,
    this.icon,
    this.textIcon,
    this.padding,
    this.spaceBetweenTextAndIcon = false,
    this.constants,
    super.key,
  });

  @override
  ButtonState createState() => ButtonState();
}

class ButtonState extends State<Button> with SingleTickerProviderStateMixin, Vibrate {
  // Animation Controller
  late AnimationController animationController;
  late Animation<double> opacityAnimation;
  late Constants constants;

  // Variables
  late Color color;

  @override
  void initState() {
    super.initState();

    if (widget.constants == null) {
      constants = Constants();
    } else {
      constants = widget.constants!;
    }

    // Initialize animation controller
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));

    // Initialize opacity animation
    opacityAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut, // Animationskurve
      ),
    );

    // Set initial color
    color = widget.color ?? Constants().blue;
  }

  @override
  void dispose() {
    animationController.dispose(); // Dispose the animation controller
    super.dispose();
  }

  // Function to handle tap
  void onTap() {
    if (widget.deactivated) return;

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
            opacity: widget.deactivated ? 0.2 : opacityAnimation.value,
            child: Container(
              width: widget.minWidth ? null : double.infinity,
              padding: widget.padding ?? const EdgeInsets.all(10),
              decoration: BoxDecoration(color: widget.color ?? color, borderRadius: widget.borderRadius ?? BorderRadius.circular(10), border: widget.border),
              child: Center(
                child:
                    !widget.loader
                        ? SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                flex: widget.spaceBetweenTextAndIcon ? 1 : 0,
                                child: Text(
                                  widget.text,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontFamily: constants.fontFamily, fontSize: constants.mediumFontSize, color: widget.fontColor ?? constants.fontColor, fontWeight: constants.medium),
                                ),
                              ),
                              if (widget.textIcon != null) ...[
                                const Gap(5),
                                Text(
                                  widget.textIcon!,
                                  style: TextStyle(fontFamily: constants.fontFamily, fontSize: constants.mediumFontSize, color: widget.fontColor ?? constants.fontColor, fontWeight: constants.medium),
                                ),
                              ],
                              if (widget.icon != null) ...[const Gap(5), widget.icon!],
                            ],
                          ),
                        )
                        : CupertinoActivityIndicator(color: widget.fontColor ?? constants.fontColor, radius: 8.0),
              ),
            ),
          );
        },
      ),
    );
  }
}
