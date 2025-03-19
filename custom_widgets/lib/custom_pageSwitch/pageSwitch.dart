import 'package:flutter/cupertino.dart';

class PageSwitch extends StatefulWidget {
  final List<Widget> items;
  final int selectedIndex;

  const PageSwitch({
    required this.items,
    required this.selectedIndex,
    super.key,
  }) : assert(items.length > 0 && items.length <= 5 && selectedIndex >= 0 && selectedIndex < items.length);

  @override
  PageSwitchState createState() => PageSwitchState();
}

class PageSwitchState extends State<PageSwitch> with SingleTickerProviderStateMixin {
  // Variables
  late AnimationController animationController;
  late Animation<double> opacityAnimation;

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

    // Initialize animation controller
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));

    // Initialize opacity animation
    opacityAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut, // Animationskurve
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      animationController.forward();
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PageSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedIndex != widget.selectedIndex) {
      animationController.reset();
      animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Opacity(
          opacity: animationController.value,
          child: widget.items[widget.selectedIndex],
        );
      },
    );
  }
}
