import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:custom_widgets/constants.dart';

class Skeleton extends StatefulWidget {
  final double height;
  final double width;
  final double borderRadius;
  final bool isOnBackground;

  const Skeleton({this.height = double.infinity, this.width = double.infinity, this.borderRadius = 12, this.isOnBackground = true, super.key});

  @override
  SkeletonState createState() => SkeletonState();
}

class SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);

    animation = Tween(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Center(
            child: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.isOnBackground ? constants.secondary.withValues(alpha: animation.value) : constants.third.withValues(alpha: animation.value),
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
            ),
          );
        },
      ),
    );
  }
}
