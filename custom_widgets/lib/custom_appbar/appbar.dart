import 'dart:io';
import 'dart:ui';
import 'package:custom_widgets/custom_frame/frame_provider.dart';
import 'package:custom_utils/custom_navigate.dart';
import 'package:custom_utils/custom_vibrate.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:custom_widgets/constants.dart';
import 'package:provider/provider.dart';

class Appbar extends StatefulWidget {
  final String? titel;
  final Widget? icon;
  final List<Widget>? actions;
  final int? userId;
  final bool isModalPopup;
  final double opacity;
  final bool showBackButton;

  const Appbar({this.titel, this.icon, this.actions, this.userId, this.isModalPopup = false, this.opacity = 0.0, this.showBackButton = false, super.key});

  @override
  AppbarState createState() => AppbarState();
}

class AppbarState extends State<Appbar> with Navigate {
  // variablen
  Map<String, dynamic> data = {};
  double appBarHeight = 0;

  // instanzen
  final GlobalKey<AppbarState> appbarKey = GlobalKey<AppbarState>();
  late final FrameProvider frameProvider;

  // standart
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

  load() async {}

  //funktionen

  void getHeight() {
    final RenderBox inputBarRenderBox = appbarKey.currentContext!.findRenderObject() as RenderBox;
    setState(() {
      appBarHeight = inputBarRenderBox.size.height;
    });
    widget.isModalPopup ? frameProvider.refreshModalPopupAppbarHeights(appBarHeight) : frameProvider.refreshAppbarHeights(appBarHeight);
  }

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();

    return GestureDetector(
      onLongPress: () {
        Vibrate().vibrateLight();
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 1 - widget.opacity,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    decoration: BoxDecoration(color: constants.background.withValues(alpha: 0.5), border: Border(bottom: BorderSide(color: constants.primary, width: 0.5))),
                    height: appBarHeight,
                  ),
                ),
              ),
            ),
          ),
          Container(
            key: appbarKey,
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + (widget.isModalPopup ? 0 : 20)),
            padding: EdgeInsets.fromLTRB(15, Platform.isIOS && !widget.isModalPopup ? 5 : 15, 15, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (!widget.isModalPopup && widget.showBackButton) ...[
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 30,
                            width: 30,
                            color: Colors.transparent,
                            child: Center(child: SizedBox(height: 15, width: 15, child: Image.asset('${constants.imgPath}arrowBack.png'))),
                          ),
                        ),
                        const Gap(10),
                      ],
                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 0.0, maxWidth: double.infinity),
                          child: Row(
                            children: [
                              if (widget.icon != null) ...[SizedBox(height: 20, child: widget.icon), const Gap(10)],
                              if (widget.titel != null)
                                Text(
                                  widget.titel!,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontFamily: constants.fontFamily, fontSize: constants.bigFontSize, color: constants.fontColor, fontWeight: constants.bold),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(10),
                widget.actions != null && widget.actions!.isNotEmpty
                    ? Wrap(spacing: 10, runSpacing: 10, children: [for (var action in widget.actions!) action])
                    : widget.isModalPopup
                    ? const Gap(0)
                    : const Gap(30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
