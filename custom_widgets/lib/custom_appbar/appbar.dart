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
  bool isBlurred = false;

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
      frameProvider.refreshIsAppbarBlurred(false);
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
    final RenderBox appBarRenderBox = appbarKey.currentContext!.findRenderObject() as RenderBox;
    setState(() {
      appBarHeight = appBarRenderBox.size.height;
    });
    widget.isModalPopup ? frameProvider.refreshModalPopupAppbarHeights(appBarHeight) : frameProvider.refreshAppbarHeights(appBarHeight);
  }

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();
    final size = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    final frameProvider = Provider.of<FrameProvider>(context, listen: true);

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
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 100),
              curve: Curves.linear,
              opacity: frameProvider.isAppbarBlurred ? 1 : 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    decoration: BoxDecoration(
                      color: constants.secondary.withValues(alpha: 0.3),
                      border: Border(
                        bottom: BorderSide(
                          color: constants.third,
                          width: 0.5,
                        ),
                      ),
                    ),
                    height: appBarHeight,
                  ),
                ),
              ),
            ),
          ),
          Container(
            key: appbarKey,
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + (widget.isModalPopup ? 0 : 10)),
            padding: EdgeInsets.fromLTRB(15, widget.isModalPopup ? 10 : 0, 15, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isModalPopup) Expanded(child: Container()),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                      ],
                      Expanded(
                        child: Row(
                          mainAxisAlignment: widget.isModalPopup ? MainAxisAlignment.center : MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[SizedBox(height: 20, child: widget.icon), const Gap(10)],
                            if (widget.titel != null)
                              Flexible(
                                child: Text(
                                  widget.titel!,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    height: 1,
                                    fontFamily: constants.fontFamily,
                                    fontSize: constants.semibigFontSize,
                                    color: constants.fontColor,
                                    fontWeight: constants.semi,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: widget.actions != null
                      ? Wrap(
                          runAlignment: WrapAlignment.center,
                          alignment: WrapAlignment.end,
                          spacing: 10,
                          runSpacing: 10,
                          children: widget.actions!.map((action) {
                            return IntrinsicWidth(child: action);
                          }).toList(),
                        )
                      : Container(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
