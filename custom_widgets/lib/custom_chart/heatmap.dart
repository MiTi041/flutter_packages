import 'package:custom_utils/custom_supabaseHelper.dart';
import 'package:custom_widgets/constants.dart';
import 'package:custom_widgets/custom_emptyState/emptyState.dart';
import 'package:custom_widgets/custom_item/item.dart';
import 'package:custom_widgets/custom_skeleton/skeleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';

class Heatmap extends StatefulWidget {
  final String titel;
  final String description;
  final Future<List<List<double>>> Function()? loadData;
  final String? unitName;
  final Color? color;
  final bool showValue;

  const Heatmap({
    super.key,
    required this.titel,
    required this.description,
    required this.loadData,
    this.color,
    this.showValue = true,
    this.unitName,
  });

  @override
  State<Heatmap> createState() => HeatmapState();
}

class HeatmapState extends State<Heatmap> with SupabaseHelper {
  // Variables
  bool isLoading = true;

  List<List<double>> heatmapData = [
    [0, 20, 30, 40, 50, 60, 70],
    [15, 25, 35, 45, 55, 65, 75],
    [20, 30, 40, 50, 60, 70, 80],
    [25, 35, 45, 55, 65, 75, 85],
    [30, 40, 50, 60, 70, 80, 90],
    [35, 45, 55, 65, 75, 85, 95],
    [40, 50, 60, 70, 80, 90, 100],
  ];

  final List<String> daysOfWeek = ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag'];

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
      heatmapData = await widget.loadData!();
    }

    setState(() {
      isLoading = false;
    });
  }

  // Functions

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();
    final size = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

    // Maximalen Wert in heatmapData finden
    double maxValue = heatmapData.expand((row) => row).reduce((a, b) => a > b ? a : b);
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
                  heatmapData.isEmpty
                      ? const EmptyState(
                          title: 'Keine Daten',
                          text: 'Es gibt noch keine Daten zu dieser Statistik',
                        )
                      : Column(
                          spacing: 5,
                          children: List.generate(
                            heatmapData.length,
                            (weekIndex) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Wochentag links anzeigen
                                  SizedBox(
                                    width: 25,
                                    child: Text(
                                      daysOfWeek[weekIndex].substring(0, 3),
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        height: 1,
                                        fontFamily: constants.fontFamily,
                                        fontSize: constants.mediumFontSize,
                                        color: constants.subFontColor,
                                        fontWeight: constants.medium,
                                      ),
                                    ),
                                  ),
                                  const Gap(10),
                                  Flexible(
                                    child: Row(
                                      spacing: 5,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: List.generate(
                                        heatmapData[weekIndex].length,
                                        (dayIndex) {
                                          double value = heatmapData[weekIndex][dayIndex];

                                          // Skalierte Farbe basierend auf maxValue
                                          double normalizedValue = value / maxValue;
                                          Color color = Color.lerp(constants.secondary, widget.color ?? constants.blue, normalizedValue > 0 ? normalizedValue.clamp(0.5, 1) : 0)!;

                                          return Flexible(
                                            child: Container(
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: color,
                                                borderRadius: BorderRadius.circular(5),
                                                border: Border.all(color: normalizedValue != 0 ? color : constants.third, width: 1),
                                              ),
                                              child: Center(
                                                child: widget.showValue && normalizedValue != 0
                                                    ? Text(
                                                        "$value",
                                                        style: TextStyle(
                                                          height: 1,
                                                          fontFamily: constants.fontFamily,
                                                          fontSize: constants.mediumFontSize,
                                                          color: constants.fontColor,
                                                          fontWeight: constants.medium,
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
                              );
                            },
                          ),
                        ),
                ],
              ),
      ],
    );
  }
}
