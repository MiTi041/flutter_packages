import 'dart:io';
import 'dart:ui';
import 'package:custom_widgets/custom_frame/frame_provider.dart';
import 'package:flutter/material.dart';
import 'package:custom_widgets/constants.dart';
import 'package:provider/provider.dart';

class Navbar extends StatefulWidget {
  final List<BottomNavigationBarItem> items;

  const Navbar({required this.items, super.key});

  @override
  NavbarState createState() => NavbarState();
}

class NavbarState extends State<Navbar> {
  // Variables
  double navBarHeight = 0;

  // Instances
  final GlobalKey<NavbarState> navbarKey = GlobalKey<NavbarState>();
  late final FrameProvider frameProvider;

  // Standard
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

    if (widget.items.length > 1) {
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
                  decoration: BoxDecoration(color: constants.background.withValues(alpha: 0.5), border: Border(top: BorderSide(color: constants.primary, width: 0.5))),
                  height: navBarHeight,
                ),
              ),
            ),
          ),
          Container(
            key: navbarKey,
            decoration: const BoxDecoration(color: Colors.transparent),
            padding: EdgeInsets.only(top: Platform.isIOS ? 20 : 0),
            height: Platform.isIOS ? 84 : 70,
            child: BottomNavigationBar(
              selectedFontSize: 0,
              unselectedFontSize: 0,
              elevation: 0,
              backgroundColor: Colors.transparent,
              currentIndex: frameProvider.navIndex,
              onTap: (int index) {
                frameProvider.changeIndex(index);
              },
              type: BottomNavigationBarType.fixed,
              items: <BottomNavigationBarItem>[for (var item in widget.items) item],
              showUnselectedLabels: false,
              showSelectedLabels: false,
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}

class NavbarItem extends StatelessWidget {
  const NavbarItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  BottomNavigationBarItem getItem({required Widget icon}) {
    return BottomNavigationBarItem(icon: SizedBox(height: 20, child: Opacity(opacity: 0.5, child: icon)), activeIcon: SizedBox(height: 20, child: icon), label: '');
  }
}
