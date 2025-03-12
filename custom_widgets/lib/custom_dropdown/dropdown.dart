import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:custom_widgets/constants.dart';

class Dropdown extends StatefulWidget {
  final String title;
  final String text;
  final List<List<dynamic>> items;
  final Future<bool> Function(dynamic)? selection;
  final dynamic preSelected;

  const Dropdown({required this.title, required this.text, required this.items, this.preSelected, this.selection, super.key});

  @override
  DropdownState createState() => DropdownState();
}

class DropdownState extends State<Dropdown> {
  // Variables
  bool isFocused = false;
  String? selectedValue;
  String? previousValue;
  GlobalKey globalKey = GlobalKey();
  double height = 25;
  OverlayEntry? overlayEntry;
  double topPosition = 0.0;

  // Instances
  final ScrollController scrollController = ScrollController();

  // Standard
  @override
  void initState() {
    super.initState();

    load();
  }

  @override
  void dispose() {
    scrollController.dispose();
    overlayEntry?.remove();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Dropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.preSelected != widget.preSelected) {
      if (widget.preSelected != null) {
        preSelect(widget.preSelected);
      }
    }
  }

  Future<void> load() async {
    validateItems();
    if (widget.preSelected != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => preSelect(widget.preSelected));
    }
  }

  // Functions
  void checkHeight() {
    setState(() {
      height = globalKey.currentContext!.size!.height;
    });
  }

  void getWidgetPosition() {
    final RenderBox renderBox = globalKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);
    setState(() {
      topPosition = position.dy + height + 10;
    });
  }

  void validateItems() {
    for (var item in widget.items) {
      if (item.length != 2) {
        throw Exception('Each item must contain exactly two elements');
      }
    }
  }

  void preSelect(value) {
    setState(() {
      selectedValue = widget.items.firstWhere((item) => item[0] == value)[1];
    });
  }

  void select(value) async {
    previousValue = selectedValue;

    final index = widget.items.indexWhere((item) => item[0] == value);
    if (index == -1) return;

    final bool success = await widget.selection?.call(widget.items[index][0]) ?? true;
    if (!success) {
      setState(() {
        selectedValue = previousValue;
      });
    } else {
      setState(() {
        selectedValue = widget.items[index][1];
        isFocused = false;
        removeOverlay();
      });
    }
  }

  void removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  void showOverlay(BuildContext context) {
    final Constants constants = Constants();
    final size = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

    checkHeight();
    getWidgetPosition();

    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isFocused = false;
                removeOverlay();
              });
            },
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: Container(decoration: BoxDecoration(color: constants.background.withValues(alpha: 0.4)))),
                ),
                Container(height: MediaQuery.of(context).size.height, width: MediaQuery.of(context).size.width, decoration: const BoxDecoration(color: Colors.transparent)),
              ],
            ),
          ),
          Center(
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.all(15),
                  width: MediaQuery.of(context).size.width,
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2),
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(color: constants.secondary, width: 1), color: constants.background, borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
                      margin: const EdgeInsets.all(5),
                      child: CustomScrollView(
                        shrinkWrap: true,
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        slivers: <Widget>[
                          SliverToBoxAdapter(
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              runAlignment: WrapAlignment.start,
                              runSpacing: 3,
                              children: widget.items
                                  .map(
                                    (List<dynamic> item) => GestureDetector(
                                      onTap: () {
                                        select(item[0]);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(15),
                                        width: double.infinity,
                                        decoration: BoxDecoration(color: selectedValue == item[1] ? constants.third : null, borderRadius: BorderRadius.circular(6)),
                                        child: Text(
                                          item[1],
                                          maxLines: 1,
                                          style: TextStyle(
                                            height: 1,
                                            fontFamily: constants.fontFamily,
                                            fontSize: constants.regularFontSize,
                                            color: constants.fontColor,
                                            fontWeight: constants.medium,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();
    final size = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isFocused = !isFocused;
              if (isFocused) {
                showOverlay(context);
              } else {
                removeOverlay();
              }
            });
          },
          child: Container(
            key: globalKey,
            padding: const EdgeInsets.all(15),
            width: double.infinity,
            decoration: BoxDecoration(
              color: isFocused ? constants.secondary : constants.primary,
              border: Border.all(color: isFocused ? constants.blue : constants.secondary, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        softWrap: true,
                        maxLines: null,
                        style: TextStyle(
                          height: 1,
                          fontFamily: constants.fontFamily,
                          fontSize: constants.regularFontSize,
                          color: constants.subFontColor,
                          fontWeight: constants.medium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Gap(5),
                      Text(
                        selectedValue == null ? widget.text : selectedValue!,
                        softWrap: true,
                        maxLines: null,
                        style: TextStyle(
                          height: 1,
                          fontFamily: constants.fontFamily,
                          fontSize: constants.semibigFontSize,
                          color: constants.fontColor,
                          fontWeight: constants.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 15),
                  child: Transform.rotate(angle: (isFocused ? 0.5 : 1.5) * 3.1415927, child: SizedBox(height: 10, child: Image.asset('${constants.imgPath}arrowBack.png'))),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
