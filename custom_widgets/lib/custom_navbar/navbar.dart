import 'dart:ui';
import 'package:custom_utils/custom_vibrate.dart';
import 'package:custom_widgets/custom_frame/desktopFrame_provider.dart';
import 'package:macos_window_utils/widgets/transparent_macos_sidebar.dart';
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
  double navbarWidth = 0;
  int selectedIndex = 0;

  // Instances
  final GlobalKey<NavbarState> navbarKey = GlobalKey<NavbarState>();
  late final DesktopFrameProvider desktopFrameProvider;

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
    desktopFrameProvider = Provider.of<DesktopFrameProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getWidth();
      load();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> load() async {}

  // Functions
  void getWidth() {
    if (navbarKey.currentContext == null) return;
    final RenderBox navbarRenderBox = navbarKey.currentContext!.findRenderObject() as RenderBox;
    setState(() {
      navbarWidth = navbarRenderBox.size.width;
    });
    desktopFrameProvider.refreshNavbarWidths(navbarWidth);
  }

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();
    final size = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    final desktopFrameProvider = Provider.of<DesktopFrameProvider>(context, listen: true);

    if (widget.items.length > 1 && widget.items.length < 6) {
      return TransparentMacOSSidebar(
        child: Stack(
          children: [
            Container(
              key: navbarKey,
              padding: EdgeInsets.fromLTRB(15, 15, 15, MediaQuery.of(context).padding.bottom),
              child: Column(
                children: List.generate(
                  widget.items.length,
                  (i) {
                    final isSelected = selectedIndex == i;

                    return GestureDetector(
                      onTap: () {
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
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
