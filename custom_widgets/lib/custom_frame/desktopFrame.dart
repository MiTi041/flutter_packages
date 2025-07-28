import 'package:custom_widgets/custom_frame/desktopFrame_provider.dart';
import 'package:custom_widgets/constants.dart';
import 'package:custom_widgets/custom_list/customList.dart';
import 'package:custom_widgets/custom_navbar/navbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:custom_utils/custom_vibrate.dart';

class DesktopFrame extends StatefulWidget {
  final Navbar? navbar;
  final Widget widget;
  final bool isPageView;
  final bool shrinkWrap;
  final ScrollController? scrollController;
  final bool reverse;
  final bool neverScrollPhysics;
  final VoidCallback? onRefresh;
  final GlobalKey<CustomListState>? customListKey;

  const DesktopFrame({
    this.navbar,
    required this.widget,
    this.isPageView = false,
    this.shrinkWrap = false,
    this.scrollController,
    this.reverse = false,
    this.neverScrollPhysics = false,
    this.onRefresh,
    this.customListKey,
    super.key,
  });

  @override
  DesktopFrameState createState() => DesktopFrameState();
}

class DesktopFrameState extends State<DesktopFrame> with Vibrate {
  // Variablen
  ScrollPhysics physics = const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  double previousPulledExtent = 0;
  bool isNearEnd = false;

  // Instanzen
  late final ScrollController scrollController;

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

    scrollController = widget.scrollController ?? ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      load();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (widget.scrollController != null) scrollController.dispose();
    super.dispose();
  }

  load() async {}

  // Funktionen

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();
    final size = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    final desktopFrameProvider = Provider.of<DesktopFrameProvider>(context, listen: true);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Row(
            children: [
              if (widget.navbar != null) widget.navbar!,
              Expanded(
                child: Container(
                  clipBehavior: Clip.none,
                  color: constants.background,
                  child: Container(
                    clipBehavior: Clip.none,
                    margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                    child: CustomScrollView(
                      scrollBehavior: CupertinoScrollBehavior(),
                      reverse: widget.reverse,
                      shrinkWrap: widget.shrinkWrap,
                      clipBehavior: Clip.none,
                      controller: scrollController,
                      physics: widget.neverScrollPhysics ? const NeverScrollableScrollPhysics() : physics,
                      slivers: <Widget>[
                        if (widget.customListKey != null || widget.onRefresh != null)
                          CupertinoSliverRefreshControl(
                            onRefresh: () async {
                              if (widget.customListKey != null) {
                                widget.customListKey!.currentState?.refresh();
                              }
                              if (widget.onRefresh != null) widget.onRefresh!();
                              vibrateHeavy();

                              await Future.delayed(const Duration(seconds: 1));
                            },
                            builder: (context, refreshState, pulledExtent, refreshTriggerPullDistance, refreshIndicatorExtent) {
                              return CupertinoSliverRefreshControl.buildRefreshIndicator(context, refreshState, pulledExtent, refreshTriggerPullDistance, refreshIndicatorExtent);
                            },
                          ),
                        SliverToBoxAdapter(
                          child: SafeArea(
                            top: false,
                            maintainBottomViewPadding: true,
                            bottom: false,
                            left: false,
                            right: false,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Gap(15),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: widget.widget,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
