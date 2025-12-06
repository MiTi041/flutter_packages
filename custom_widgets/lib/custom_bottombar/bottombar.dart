import 'dart:ui';
import 'package:custom_utils/custom_vibrate.dart';
import 'package:custom_widgets/custom_frame/frame_provider.dart';
import 'bottombarItem.dart';
import 'package:flutter/material.dart';
import 'package:custom_widgets/constants.dart';
import 'package:provider/provider.dart';

enum BottombarThemes { Normal, LiquidGlass }

class Bottombar extends StatefulWidget {
  final List<BottombarItem> items;
  final double blurValue;
  final BottombarThemes theme;

  const Bottombar({
    required this.items,
    this.blurValue = 0.3,
    this.theme = BottombarThemes.Normal,
    super.key,
  });

  @override
  BottombarState createState() => BottombarState();
}

class BottombarState extends State<Bottombar> with Vibrate, SingleTickerProviderStateMixin {
  // Variables
  double bottombarHeight = 40;
  int selectedIndex = 0;

  late AnimationController _controller;
  late Animation<double> _animation;
  double _indicatorX = 0.0; // aktuelle Position
  double _targetX = 0.0; // Zielposition
  double _itemWidth = 0.0;

  // Instances
  final GlobalKey<BottombarState> bottombarKey = GlobalKey<BottombarState>();
  late final FrameProvider frameProvider;

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
    frameProvider = Provider.of<FrameProvider>(context, listen: false);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addListener(() {
        setState(() {
          _indicatorX = _animation.value;
        });
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getHeight();
      load();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> load() async {}

  // Functions
  void getHeight() {
    if (bottombarKey.currentContext == null) return;
    final RenderBox inputBarRenderBox = bottombarKey.currentContext!.findRenderObject() as RenderBox;
    setState(() {
      bottombarHeight = inputBarRenderBox.size.height;
    });
    frameProvider.refreshBottombarHeights(bottombarHeight);
  }

  void _onItemTap(int index) {
    vibrateLight();
    if (selectedIndex == index) return;

    setState(() {
      selectedIndex = index;
    });

    // Zielposition berechnen
    _targetX = index * _itemWidth;
    _animation = Tween<double>(begin: _indicatorX, end: _targetX).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward(from: 0);

    widget.items[index].click?.call();
  }

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();
    final frameProvider = Provider.of<FrameProvider>(context, listen: true);

    if (widget.items.length < 2 || widget.items.length > 5) return const SizedBox.shrink();

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final color = constants.secondary.withValues(alpha: widget.blurValue);
    _itemWidth = (MediaQuery.of(context).size.width - 60) / widget.items.length;

    if (widget.theme == BottombarThemes.LiquidGlass) {
      return Stack(
        children: [
          Positioned(
            bottom: 30,
            left: 30,
            right: 30,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(50)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: constants.secondary.withValues(alpha: widget.blurValue),
                  ),
                  height: bottombarHeight - 30,
                ),
              ),
            ),
          ),

          // Das bewegliche Highlight
          AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            bottom: 35,
            left: 30 + _indicatorX + 5,
            child: Container(
              width: _itemWidth - 10,
              height: bottombarHeight - 40,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),

          // Die eigentlichen Icons/Text
          Container(
            key: bottombarKey,
            margin: const EdgeInsets.fromLTRB(30, 0, 30, 30),
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(50)),
              border: Border.all(
                color: constants.third,
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(widget.items.length, (i) {
                final isSelected = selectedIndex == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onItemTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedOpacity(
                      opacity: isSelected ? 1.0 : 0.6,
                      duration: const Duration(milliseconds: 100),
                      child: Center(
                        child: BottombarItem(
                          iconActive: widget.items[i].iconActive,
                          iconInactive: widget.items[i].iconInactive,
                          text: widget.items[i].text,
                          isSelected: isSelected,
                          activeColor: widget.items[i].activeColor,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      );
    }

    // Fallback: normale Variante ohne Animation
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                decoration: BoxDecoration(
                  color: constants.secondary.withValues(alpha: widget.blurValue),
                  border: Border(
                    top: BorderSide(
                      color: constants.third,
                      width: 0.5,
                    ),
                  ),
                ),
                height: bottombarHeight,
              ),
            ),
          ),
        ),
        Container(
          key: bottombarKey,
          decoration: const BoxDecoration(color: Colors.transparent),
          padding: EdgeInsets.fromLTRB(15, 15, 15, MediaQuery.of(context).padding.bottom),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              widget.items.length,
              (i) {
                final isSelected = selectedIndex == i;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      vibrateLight();
                      if (selectedIndex != i) {
                        setState(() => selectedIndex = i);
                      }
                      if (widget.items[i].click != null) {
                        widget.items[i].click!();
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
                        child: BottombarItem(
                          iconActive: widget.items[i].iconActive,
                          iconInactive: widget.items[i].iconInactive,
                          text: widget.items[i].text,
                          isSelected: isSelected,
                          activeColor: widget.items[i].activeColor,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
