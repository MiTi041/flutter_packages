import 'dart:ui';
import 'package:custom_utils/custom_vibrate.dart';
import 'package:custom_widgets/custom_frame/frame_provider.dart';
import 'navbarItem.dart';
import 'package:flutter/material.dart';
import 'package:custom_widgets/constants.dart';
import 'package:provider/provider.dart';

class Navbar extends StatefulWidget {
  final List<NavbarItem> items;

  const Navbar({required this.items, super.key});

  @override
  NavbarState createState() => NavbarState();
}

class NavbarState extends State<Navbar> with Vibrate {
  // Variables
  double navBarHeight = 0;
  int selectedIndex = 0;

  // Instances
  final GlobalKey<NavbarState> navbarKey = GlobalKey<NavbarState>();
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getHeight();
      load();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> load() async {}

  // Functions
  void getHeight() {
    if (navbarKey.currentContext == null) return;
    final RenderBox inputBarRenderBox = navbarKey.currentContext!.findRenderObject() as RenderBox;
    setState(() {
      navBarHeight = inputBarRenderBox.size.height;
    });
    frameProvider.refreshBottombarHeights(navBarHeight);
  }

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();
    final frameProvider = Provider.of<FrameProvider>(context, listen: true);

    if (widget.items.length > 1 && widget.items.length < 6) {
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
                    color: constants.secondary.withValues(alpha: 0.3),
                    border: Border(
                      top: BorderSide(
                        color: constants.third,
                        width: 0.5,
                      ),
                    ),
                  ),
                  height: navBarHeight,
                ),
              ),
            ),
          ),
          Container(
            key: navbarKey,
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
                          child: NavbarItem(
                            iconActive: widget.items[i].iconActive,
                            iconInactive: widget.items[i].iconInactive,
                            text: widget.items[i].text,
                            isSelected: isSelected,
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
    } else {
      return Container();
    }
  }
}
