import 'package:custom_utils/custom_vibrate.dart';
import 'package:custom_widgets/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';

class Toggle extends StatefulWidget {
  final bool preSelectedValue;
  final Color? color;
  final Color? fontColor;
  final Color? subFontColor;
  final double? width;
  final bool minWidth;
  final String? text;
  final String? toggledText;
  final IconData? iconActive;
  final IconData? iconInactive;
  final Future<bool> Function(bool value)? onToggle;
  final BorderRadius? borderRadius;
  final bool shrink;

  const Toggle({
    this.preSelectedValue = false,
    this.color,
    this.fontColor,
    this.subFontColor,
    this.width,
    this.minWidth = false,
    this.text,
    this.toggledText,
    this.iconActive,
    this.iconInactive,
    this.onToggle,
    this.borderRadius,
    this.shrink = false,
    super.key,
  });

  @override
  ToggleState createState() => ToggleState();
}

class ToggleState extends State<Toggle> {
  // Variables
  late bool isToggled;

  // Instances

  // Standard
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    isToggled = widget.preSelectedValue;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      load();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Toggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.preSelectedValue != widget.preSelectedValue) {
      if (widget.preSelectedValue) {
        setState(() {
          isToggled = widget.preSelectedValue;
        });
      }
    }
  }

  Future<void> load() async {}

  // Functions
  Future<void> toggle() async {
    Vibrate().vibrateLight();
    final newState = !isToggled;

    if (await widget.onToggle?.call(newState) ?? true) {
      Vibrate().vibrateSuccess();
      isToggled = newState;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();
    final size = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

    return GestureDetector(
      onTap: () {
        toggle();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        width: widget.width,
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
        decoration: BoxDecoration(
          color: isToggled ? widget.color ?? constants.blue : constants.secondary,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: widget.shrink ? MainAxisSize.min : MainAxisSize.max,
          children: [
            if (isToggled && widget.iconActive != null || !isToggled && widget.iconInactive != null) ...[
              Icon(isToggled ? widget.iconActive : widget.iconInactive, size: 14, color: isToggled ? widget.fontColor ?? constants.fontColor : widget.subFontColor ?? constants.subFontColor),
              const Gap(5),
            ],
            if (widget.toggledText != null || widget.text != null)
              Text(
                (isToggled && widget.toggledText != null || widget.text != '') ? widget.toggledText ?? widget.text! : widget.text ?? widget.toggledText!,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: constants.fontFamily,
                  fontSize: constants.semibigFontSize,
                  height: 1,
                  color: isToggled ? widget.fontColor ?? constants.fontColor : widget.subFontColor ?? constants.subFontColor,
                  fontWeight: constants.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
