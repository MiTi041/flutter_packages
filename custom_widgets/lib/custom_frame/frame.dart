import 'dart:math';
import 'package:custom_widgets/custom_frame/frame_provider.dart';
import 'package:custom_widgets/constants.dart';
import 'package:custom_widgets/custom_list/customList.dart';
import 'package:custom_widgets/custom_navbar/navbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:custom_utils/custom_vibrate.dart';

class Frame extends StatefulWidget {
  final Widget? appbar;
  final Widget? bottombar;
  final Widget widget;
  final bool isPageView;
  final bool shrinkWrap;
  final bool resizeToAvoidBottomInsets;
  final ScrollController? scrollController;
  final bool reverse;
  final bool neverScrollPhysics;
  final bool showBottomGap;
  final VoidCallback? onRefresh;
  final GlobalKey<CustomListState>? customListKey;
  final bool isModalPopup;

  const Frame({
    this.appbar,
    this.bottombar,
    required this.widget,
    this.isPageView = false,
    this.shrinkWrap = false,
    this.resizeToAvoidBottomInsets = false,
    this.scrollController,
    this.reverse = false,
    this.neverScrollPhysics = false,
    this.showBottomGap = true,
    this.onRefresh,
    this.customListKey,
    this.isModalPopup = false,
    super.key,
  });

  @override
  FrameState createState() => FrameState();
}

class FrameState extends State<Frame> with Vibrate {
  // Variablen
  ScrollPhysics physics = const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  double previousPulledExtent = 0;
  bool isNearEnd = false;

  // Instanzen
  late final ScrollController scrollController;

  // Standard
  @override
  void initState() {
    super.initState();

    scrollController = widget.scrollController ?? ScrollController();

    scrollController.addListener(() {
      // um die appbar zu verändern wenn etwas unter ihr ist
      double offset = scrollController.offset;

      if (offset > 0 && Provider.of<FrameProvider>(context, listen: false).isAppbarBlurred == false) {
        Provider.of<FrameProvider>(context, listen: false).refreshIsAppbarBlurred(true);
      } else if (offset <= 0 && Provider.of<FrameProvider>(context, listen: false).isAppbarBlurred == true) {
        Provider.of<FrameProvider>(context, listen: false).refreshIsAppbarBlurred(false);
      }

      // um zu sagen ob die liste am ende ist
      if (widget.customListKey != null) {
        if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 300) {
          // Fast am Ende der Liste
          if (!isNearEnd) {
            setState(() {
              isNearEnd = true;

              widget.customListKey!.currentState?.load(withoutLoading: true, activateLoadMoreLoader: true);
            });
          }
        } else {
          setState(() {
            isNearEnd = false;
          });
        }
      }
    });

    load();
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
    final frameProvider = Provider.of<FrameProvider>(context, listen: true);

    return Material(
      color: constants.background,
      child: Stack(
        children: [
          widget.isPageView
              ? Container(clipBehavior: Clip.none, margin: const EdgeInsets.only(left: 15, right: 15), child: Column(children: [widget.widget]))
              : Container(
                  clipBehavior: Clip.none,
                  margin: EdgeInsets.only(left: 15, right: 15, bottom: widget.bottombar != null ? 0 : 15),
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
                            if (widget.customListKey != null) widget.customListKey!.currentState?.refresh();
                            if (widget.onRefresh != null) widget.onRefresh!();
                            vibrateHeavy();

                            await Future.delayed(const Duration(seconds: 1));
                          },
                          builder: (context, refreshState, pulledExtent, refreshTriggerPullDistance, refreshIndicatorExtent) {
                            return Padding(
                              padding: EdgeInsets.only(top: widget.appbar != null ? frameProvider.appbarHeight : 0),
                              child: CupertinoSliverRefreshControl.buildRefreshIndicator(context, refreshState, pulledExtent, refreshTriggerPullDistance, refreshIndicatorExtent),
                            );
                          },
                        ),
                      SliverToBoxAdapter(
                        child: SafeArea(
                          top: false,
                          maintainBottomViewPadding: true,
                          bottom: widget.bottombar == null ? true : false,
                          left: false,
                          right: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              widget.isModalPopup ? Gap(frameProvider.modalPopupAppbarHeight) : Gap(widget.appbar != null ? frameProvider.appbarHeight : 0),
                              const Gap(15),
                              widget.widget,
                              if (!widget.isModalPopup) Gap(max(0, MediaQuery.of(context).viewInsets.bottom)),
                              if (widget.bottombar != null && widget.showBottomGap) ...[if (widget.bottombar is Navbar) Gap(frameProvider.bottombarHeight + 15)],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          if (widget.appbar != null) Positioned(top: 0, left: 0, right: 0, child: widget.appbar!),
          if (widget.bottombar != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(padding: widget.resizeToAvoidBottomInsets ? EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom) : EdgeInsets.zero, child: widget.bottombar!),
            ),
        ],
      ),
    );
  }
}
