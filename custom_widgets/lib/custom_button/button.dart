import 'package:custom_widgets/custom_clickAnimationWrap.dart/clickAnimationWrap.dart';
import 'package:gap/gap.dart';
import 'package:custom_utils/custom_vibrate.dart';
import 'package:custom_widgets/constants.dart';
import 'package:flutter/cupertino.dart';

class Button extends StatefulWidget {
  final Color? color;
  final String? text;
  final bool loader;
  final bool minWidth;
  final BorderRadius borderRadius;
  final Border? border;
  final Color? fontColor;
  final bool deactivated;
  final bool noAnimation;
  final String? textIcon;
  final IconData? icon;
  final EdgeInsets? padding;
  final bool spaceBetweenTextAndIcon;

  final VoidCallback? click;

  const Button({
    this.text,
    this.color,
    this.loader = false,
    this.deactivated = false,
    this.noAnimation = false,
    this.minWidth = false,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.border,
    this.fontColor,
    this.click,
    this.icon,
    this.textIcon,
    this.padding,
    this.spaceBetweenTextAndIcon = false,
    super.key,
  });

  @override
  ButtonState createState() => ButtonState();
}

class ButtonState extends State<Button> with SingleTickerProviderStateMixin, Vibrate {
  // Animation Controller
  late AnimationController animationController;
  late Animation<double> opacityAnimation;

  // Variables
  late Color color;

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

    // Set initial color
    color = widget.color ?? Constants().blue;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  // Function to handle tap
  void onTap() {
    if (widget.deactivated) return;
    // Vibrate and trigger click
    vibrateLight();
    if (widget.click != null) widget.click!();
  }

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();
    final size = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

    return ClickAnimationWrap(
      disabled: widget.noAnimation || widget.deactivated,
      onTap: onTap,
      child: Opacity(
        opacity: widget.deactivated ? 0.5 : 1,
        child: Container(
          width: widget.minWidth ? null : double.infinity,
          padding: widget.padding ?? const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: widget.color ?? color,
            borderRadius: widget.borderRadius,
            border: widget.border,
          ),
          child: Center(
            child: !widget.loader
                ? SizedBox(
                    width: widget.minWidth ? null : double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (widget.text != null) ...[
                          Expanded(
                            flex: widget.spaceBetweenTextAndIcon ? 1 : 0,
                            child: Text(
                              widget.text!,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                height: 1,
                                fontFamily: constants.fontFamily,
                                fontSize: constants.mediumFontSize,
                                color: widget.fontColor ?? constants.fontColor,
                                fontWeight: constants.medium,
                              ),
                            ),
                          ),
                          const Gap(5),
                        ],
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 15, color: widget.fontColor ?? constants.fontColor),
                        ],
                      ],
                    ),
                  )
                : CupertinoActivityIndicator(color: widget.fontColor ?? constants.fontColor, radius: 7.5),
          ),
        ),
      ),
    );
  }
}
