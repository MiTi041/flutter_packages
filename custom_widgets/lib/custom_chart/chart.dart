import 'package:custom_utils/custom_supabaseHelper.dart';
import 'package:custom_widgets/constants.dart';
import 'package:custom_widgets/custom_emptyState/emptyState.dart';
import 'package:custom_widgets/custom_item/item.dart';
import 'package:custom_widgets/custom_skeleton/skeleton.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';

class Chart extends StatefulWidget {
  final String titel;
  final String description;
  final String? unitName;
  final Future<List<FlSpot>> Function()? loadData;
  final bool showChangeRate;
  final bool showStats;

  const Chart({
    super.key,
    required this.titel,
    required this.description,
    this.unitName,
    this.loadData,
    this.showChangeRate = true,
    this.showStats = true,
  });

  @override
  State<Chart> createState() => ChartState();
}

class ChartState extends State<Chart> with SupabaseHelper {
  // Variables
  bool isLoading = true;
  List<FlSpot> chartData = [];
  double average = 0;
  double maxValue = 0;
  double minValue = 0;
  double changeRate = 0;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      load();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> load() async {
    setState(() {
      isLoading = true;
    });

    if (widget.loadData != null) {
      chartData = await widget.loadData!();
    }

    average = chartData.isEmpty ? 0 : chartData.map((spot) => spot.y).reduce((sum, value) => sum + value) / chartData.length;
    maxValue = chartData.isEmpty ? 0 : chartData.map((spot) => spot.y).reduce((max, value) => value > max ? value : max);
    minValue = chartData.isEmpty ? 0 : chartData.map((spot) => spot.y).reduce((min, value) => value < min ? value : min);

    if (chartData.length > 1) {
      double previousValue = chartData[chartData.length - 2].y; // Wert des vorletzten Eintrags
      double currentValue = chartData.last.y; // Wert des letzten Eintrags

      // Berechnung des prozentualen Anstiegs
      changeRate = previousValue == 0 ? 0 : ((currentValue - previousValue) / previousValue) * 100;
    } else {
      changeRate = 0;
    }

    setState(() {
      isLoading = false;
    });
  }

  // Functions

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isLoading
            ? Skeleton(height: 170)
            : Item(
                titel: widget.titel,
                subTitel: widget.description,
                content: [
                  chartData.isEmpty
                      ? const EmptyState(
                          title: 'Keine Daten',
                          text: 'Es gibt noch keine Daten zu dieser Statistik',
                        )
                      : Column(
                          children: [
                            if (widget.showStats) ...[
                              SizedBox(
                                width: double.infinity,
                                child: Wrap(
                                  spacing: 5,
                                  runSpacing: 5,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: constants.secondary,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Durchschnitt: ${average.toStringAsFixed(1)}',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          height: 1,
                                          fontFamily: constants.fontFamily,
                                          fontSize: constants.mediumFontSize,
                                          color: constants.subFontColor,
                                          fontWeight: constants.medium,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: constants.secondary,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Maximal:  ${maxValue.toStringAsFixed(1)}',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          height: 1,
                                          fontFamily: constants.fontFamily,
                                          fontSize: constants.mediumFontSize,
                                          color: constants.subFontColor,
                                          fontWeight: constants.medium,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: constants.secondary,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Minimum:  ${minValue.toStringAsFixed(1)}',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          height: 1,
                                          fontFamily: constants.fontFamily,
                                          fontSize: constants.mediumFontSize,
                                          color: constants.subFontColor,
                                          fontWeight: constants.medium,
                                        ),
                                      ),
                                    ),
                                    if (widget.showChangeRate)
                                      Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: constants.secondary,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${changeRate.toStringAsFixed(1)} %',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                height: 1,
                                                fontFamily: constants.fontFamily,
                                                fontSize: constants.mediumFontSize,
                                                color: changeRate > 0
                                                    ? constants.green
                                                    : changeRate < 0
                                                        ? constants.red
                                                        : constants.subFontColor,
                                                fontWeight: constants.medium,
                                              ),
                                            ),
                                            const Gap(5),
                                            if (changeRate > 0) Icon(CupertinoIcons.arrow_up_right, size: 12, color: constants.green),
                                            if (changeRate < 0) Icon(CupertinoIcons.arrow_down_right, size: 12, color: constants.red),
                                            if (changeRate == 0) Icon(CupertinoIcons.minus, size: 12, color: constants.subFontColor),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const Gap(10),
                            ],
                            SizedBox(
                              height: 100,
                              child: LineChart(
                                LineChartData(
                                  lineTouchData: LineTouchData(
                                    enabled: true,
                                    touchTooltipData: LineTouchTooltipData(
                                      tooltipBorder: BorderSide(color: constants.third, width: 1),
                                      getTooltipColor: (LineBarSpot touchedSpots) {
                                        return constants.secondary;
                                      },
                                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                        return touchedSpots.map((touchedSpot) {
                                          return LineTooltipItem(
                                            "${touchedSpot.y.toInt()} ${widget.unitName ?? ""}",
                                            TextStyle(
                                              height: 1,
                                              color: constants.fontColor,
                                              fontSize: constants.mediumFontSize,
                                              fontFamily: constants.fontFamily,
                                              fontWeight: constants.medium,
                                            ),
                                          );
                                        }).toList();
                                      },
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    show: false,
                                  ), // to disable all tiles in graph
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: (maxValue / 5).clamp(1, double.infinity),
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(color: constants.secondary, width: 1),
                                  ),
                                  minX: 0,
                                  maxX: chartData.isNotEmpty ? chartData.length - 1 : 1,
                                  minY: 0,
                                  maxY: maxValue + maxValue / 6,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: chartData,
                                      isCurved: true,
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      color: constants.blue,
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [constants.blue.withValues(alpha: 0.3), CupertinoColors.transparent],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
      ],
    );
  }
}
