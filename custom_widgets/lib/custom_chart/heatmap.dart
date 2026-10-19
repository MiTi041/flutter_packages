import 'dart:math' as math;

import 'package:custom_utils/custom_supabaseHelper.dart';
import 'package:custom_widgets/constants.dart';
import 'package:custom_widgets/custom_emptyState/emptyState.dart';
import 'package:custom_widgets/custom_item/item.dart';
import 'package:custom_widgets/custom_skeleton/skeleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:gap/gap.dart';

class Heatmap extends StatefulWidget {
  final String titel;
  final String? description;
  final Future<List<List<double>>> Function()? loadData;
  final String? unitName;
  final Color? color;
  final bool showValue;
  final bool showWeekLabels;

  const Heatmap({
    super.key,
    required this.titel,
    this.description,
    required this.loadData,
    this.color,
    this.showValue = true,
    this.showWeekLabels = false,
    this.unitName,
  });

  @override
  State<Heatmap> createState() => HeatmapState();
}

class HeatmapState extends State<Heatmap> with SupabaseHelper {
  // Variables
  bool isLoading = true;

  List<List<double>> heatmapData = List.generate(7, (_) => List.filled(10, 0));

  final ScrollController _scrollController = ScrollController();

  int? _visibleYear;
  DateTime? _startDate;
  double _cellExtent = 0;
  int _columns = 0;

  final List<String> daysOfWeek = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  // Instances

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
    _scrollController.addListener(_updateVisibleYear);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      load();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateVisibleYear);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateVisibleYear() {
    if (_startDate == null || _cellExtent <= 0 || _columns == 0) return;
    // Rechts ist die neueste Woche; das Jahr der neuesten sichtbaren Spalte zählt.
    final position = _scrollController.position;
    final index = (_columns - 1 - (position.pixels / _cellExtent).floor())
        .clamp(0, _columns - 1);
    final year = _isoYear(_startDate!.add(Duration(days: 7 * index)));
    if (year != _visibleYear) setState(() => _visibleYear = year);
  }

  static DateTime _mondayOf(DateTime date) =>
      DateTime(date.year, date.month, date.day)
          .subtract(Duration(days: date.weekday - 1));

  // ISO-Jahr, damit z. B. KW 1 auch im Dezember das passende Jahr zeigt.
  static int _isoYear(DateTime date) =>
      date.add(Duration(days: 4 - date.weekday)).year;

  static int _isoWeek(DateTime date) {
    final thursday = date.add(Duration(days: 4 - date.weekday));
    final firstDayOfYear = DateTime(thursday.year, 1, 1);
    return thursday.difference(firstDayOfYear).inDays ~/ 7 + 1;
  }

  Future<void> load() async {
    setState(() {
      isLoading = true;
    });

    if (widget.loadData != null) {
      heatmapData = await widget.loadData!();
      //print(heatmapData);
    }

    // Letzte Spalte ist die aktuelle Woche, also startet die Ansicht rechts.
    _visibleYear = _isoYear(DateTime.now());
    _startDate = null;

    setState(() {
      isLoading = false;
    });
  }

  // Functions

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();
    final size = WidgetsBinding
            .instance.platformDispatcher.views.first.physicalSize /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

    // Maximalen Wert in heatmapData finden
    double maxValue = heatmapData.isEmpty || heatmapData.first.isEmpty
        ? 1
        : heatmapData.expand((row) => row).reduce((a, b) => a > b ? a : b);
    maxValue = maxValue > 0 ? maxValue : 1; // Verhindert Division durch 0

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isLoading
            ? Skeleton(height: 200)
            : Item(
                titel: widget.titel,
                subTitel: widget.description,
                content: [
                  heatmapData.isEmpty || heatmapData.first.isEmpty
                      ? const EmptyState(
                          title: 'Keine Daten',
                          text: 'Es gibt noch keine Daten zu dieser Statistik',
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            const double gap = 5;
                            const double labelWidth = 30;
                            const double cellWidth = 22;
                            final int columns = heatmapData.first.length;
                            final double availableWidth =
                                constraints.maxWidth - labelWidth - 10;
                            final int visibleColumns = math.max(
                              columns,
                              math.max(
                                  1,
                                  ((availableWidth + gap) / (cellWidth + gap))
                                      .floor()),
                            );
                            final int dummyColumns = visibleColumns - columns;
                            final double gridWidth =
                                visibleColumns * cellWidth +
                                    gap * (visibleColumns - 1);
                            // Daten enden in der aktuellen Woche; Dummy-Spalten liegen davor.
                            final DateTime startDate = _mondayOf(DateTime.now())
                                .subtract(
                                    Duration(days: 7 * (visibleColumns - 1)));
                            _startDate = startDate;
                            _columns = visibleColumns;
                            _cellExtent = cellWidth + gap;

                            final textStyle = TextStyle(
                              height: 1,
                              fontFamily: constants.fontFamily,
                              fontSize: constants.mediumFontSize,
                              color: constants.subFontColor,
                              fontWeight: constants.medium,
                            );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.showWeekLabels) ...[
                                  Row(
                                    children: [
                                      const SizedBox(width: labelWidth),
                                      const Gap(10),
                                      Text(
                                        '${_visibleYear ?? _isoYear(DateTime.now())}',
                                        style: textStyle,
                                      ),
                                    ],
                                  ),
                                  const Gap(gap),
                                ],
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Wochentage bleiben beim Scrollen stehen
                                    Column(
                                      spacing: gap,
                                      children: [
                                        if (widget.showWeekLabels)
                                          SizedBox(
                                            width: labelWidth,
                                            height: 16,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child:
                                                  Text('KW', style: textStyle),
                                            ),
                                          ),
                                        ...List.generate(
                                          7,
                                          (dayIndex) => SizedBox(
                                            width: labelWidth,
                                            height: cellWidth,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(daysOfWeek[dayIndex],
                                                  style: textStyle),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Gap(10),
                                    Expanded(
                                      child: _EdgeFade(
                                        controller: _scrollController,
                                        scrollable: gridWidth > availableWidth,
                                        child: SingleChildScrollView(
                                          controller: _scrollController,
                                          scrollDirection: Axis.horizontal,
                                          // reverse: neueste Woche steht rechts und
                                          // ist ohne Scrollen sofort sichtbar.
                                          reverse: true,
                                          child: Column(
                                            spacing: gap,
                                            children: [
                                              if (widget.showWeekLabels)
                                                Row(
                                                  spacing: gap,
                                                  children: List.generate(
                                                    visibleColumns,
                                                    (weekIndex) => SizedBox(
                                                      width: cellWidth,
                                                      height: 16,
                                                      child: Center(
                                                        child: Text(
                                                          _isoWeek(startDate
                                                                  .add(Duration(
                                                                      days: 7 *
                                                                          weekIndex)))
                                                              .toString(),
                                                          style: textStyle,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ...List.generate(
                                                7,
                                                (dayIndex) => Row(
                                                  spacing: gap,
                                                  children: List.generate(
                                                    visibleColumns,
                                                    (displayIndex) {
                                                      final int weekIndex =
                                                          displayIndex -
                                                              dummyColumns;
                                                      if (weekIndex < 0) {
                                                        return SizedBox(
                                                          width: cellWidth,
                                                          height: cellWidth,
                                                        );
                                                      }
                                                      double value =
                                                          heatmapData[dayIndex]
                                                              [weekIndex];

                                                      bool
                                                          isFutureDayInCurrentWeek =
                                                          false;
                                                      if (weekIndex ==
                                                          columns - 1) {
                                                        // Letzte Woche (aktuelle Woche)
                                                        if (dayIndex >
                                                            DateTime.now()
                                                                    .weekday -
                                                                1) {
                                                          // Tag liegt nach heute
                                                          isFutureDayInCurrentWeek =
                                                              true;
                                                        }
                                                      }

                                                      // Wenn Tag in Zukunft => einfach leeres Kästchen zeichnen
                                                      if (isFutureDayInCurrentWeek) {
                                                        return SizedBox(
                                                          width: cellWidth,
                                                          height: cellWidth,
                                                          child: Container(
                                                            decoration:
                                                                const BoxDecoration(
                                                                    color:
                                                                        null),
                                                          ),
                                                        );
                                                      }

                                                      double normalizedValue =
                                                          value / maxValue;
                                                      Color color = Color.lerp(
                                                          constants.secondary,
                                                          widget.color ??
                                                              constants.blue,
                                                          normalizedValue > 0
                                                              ? normalizedValue
                                                                  .clamp(0.5, 1)
                                                              : 0)!;

                                                      return SizedBox(
                                                        width: cellWidth,
                                                        height: cellWidth,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: color,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            border: Border.all(
                                                                color: normalizedValue !=
                                                                        0
                                                                    ? color
                                                                    : constants
                                                                        .third,
                                                                width: 1),
                                                          ),
                                                          child: Center(
                                                            child: widget
                                                                        .showValue &&
                                                                    normalizedValue !=
                                                                        0
                                                                ? Text(
                                                                    "$value$dayIndex",
                                                                    style:
                                                                        TextStyle(
                                                                      height: 1,
                                                                      fontFamily:
                                                                          constants
                                                                              .fontFamily,
                                                                      fontSize:
                                                                          constants
                                                                              .mediumFontSize,
                                                                      color: constants
                                                                          .fontColor,
                                                                      fontWeight:
                                                                          constants
                                                                              .medium,
                                                                    ),
                                                                  )
                                                                : const SizedBox(),
                                                          ),
                                                        ),
                                                      );
                                                    },
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
                            );
                          },
                        ),
                ],
              ),
      ],
    );
  }
}

// ponytail: Flutter-natives ShaderMask statt zusätzlicher Dependency.
// Blendet nur an den Seiten aus, an denen tatsächlich weiterer Inhalt liegt.
class _EdgeFade extends StatefulWidget {
  const _EdgeFade(
      {required this.controller,
      required this.scrollable,
      required this.child});

  final ScrollController controller;
  final bool scrollable;
  final Widget child;

  @override
  State<_EdgeFade> createState() => _EdgeFadeState();
}

class _EdgeFadeState extends State<_EdgeFade> {
  bool _atStart = true;
  bool _atEnd = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void didUpdateWidget(covariant _EdgeFade oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_update);
      widget.controller.addListener(_update);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    super.dispose();
  }

  void _update() {
    if (!mounted || !widget.controller.hasClients) return;
    final position = widget.controller.position;
    final atStart = position.pixels <= position.minScrollExtent + 1;
    final atEnd = position.pixels >= position.maxScrollExtent - 1;
    if (atStart != _atStart || atEnd != _atEnd) {
      setState(() {
        _atStart = atStart;
        _atEnd = atEnd;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.scrollable) return widget.child;

    const double fade = 0.08;
    // reverse: Offset 0 liegt rechts, daher sind Start/Ende vertauscht.
    final double left = _atEnd ? 0 : fade;
    final double right = _atStart ? 0 : fade;

    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: const [
          Colors.transparent,
          Colors.black,
          Colors.black,
          Colors.transparent
        ],
        stops: [0, left, 1 - right, 1],
      ).createShader(bounds),
      child: widget.child,
    );
  }
}
