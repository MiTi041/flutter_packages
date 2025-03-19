import 'package:flutter/cupertino.dart';
import 'package:local_auth/local_auth.dart';

class ClickAnimationWrap extends StatefulWidget {
  final Widget child;
  final bool disabled;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ClickAnimationWrap({
    super.key,
    required this.child,
    this.disabled = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  ClickAnimationWrapState createState() => ClickAnimationWrapState();
}

class ClickAnimationWrapState extends State<ClickAnimationWrap> with SingleTickerProviderStateMixin {
  // Variables
  late AnimationController animationController;
  late Animation<double> opacityAnimation;

  // Instances
  final LocalAuthentication auth = LocalAuthentication();

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
    animationController.dispose();
    super.dispose();
  }

  // Functions

  @override
  Widget build(BuildContext context) {
    if (widget.disabled) return widget.child;

    return GestureDetector(
      onTap: () {
        if (widget.onTap == null) return;
        // Start the animation
        animationController.forward().then((_) {
          // Reverse the animation after it completes
          animationController.reverse();
        });
        widget.onTap!();
      },
      onLongPress: () {
        if (widget.onLongPress == null) return;
        // Start the animation
        animationController.forward().then((_) {
          // Reverse the animation after it completes
          animationController.reverse();
        });
        widget.onLongPress!();
      },
      child: AnimatedBuilder(
          animation: opacityAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: opacityAnimation.value,
              child: widget.child,
            );
          }),
    );
  }
}
