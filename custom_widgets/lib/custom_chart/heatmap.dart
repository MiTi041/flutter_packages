import 'package:custom_utils/custom_supabaseHelper.dart';
import 'package:custom_widgets/constants.dart';
import 'package:custom_widgets/custom_emptyState/emptyState.dart';
import 'package:custom_widgets/custom_item/item.dart';
import 'package:custom_widgets/custom_skeleton/skeleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';

class Heatmap extends StatefulWidget {
  final String titel;
  final String? description;
  final Future<List<List<double>>> Function()? loadData;
  final String? unitName;
  final Color? color;
  final bool showValue;

  const Heatmap({
    super.key,
    required this.titel,
    this.description,
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

  List<List<double>> heatmapData = List.generate(7, (_) => List.filled(10, 0));

  final List<String> daysOfWeek = ['Monday', 'Thuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

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
      //print(heatmapData);
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
                            7,
                            (dayIndex) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Wochentag
                                  SizedBox(
                                    width: 30,
                                    child: Text(
                                      daysOfWeek[dayIndex].substring(0, 3),
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
                                        heatmapData[dayIndex].length,
                                        (weekIndex) {
                                          double value = heatmapData[dayIndex][weekIndex];

                                          bool isFutureDayInCurrentWeek = false;
                                          if (weekIndex == heatmapData[dayIndex].length - 1) {
                                            // Letzte Woche (aktuelle Woche)
                                            if (dayIndex > DateTime.now().weekday - 1) {
                                              // Tag liegt nach heute
                                              isFutureDayInCurrentWeek = true;
                                            }
                                          }

                                          // Wenn Tag in Zukunft => einfach leeres Kästchen zeichnen
                                          if (isFutureDayInCurrentWeek) {
                                            value = 0;
                                            return Flexible(
                                              child: Container(
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  color: null,
                                                ),
                                              ),
                                            );
                                          }

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
                                                        "$value$dayIndex",
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
