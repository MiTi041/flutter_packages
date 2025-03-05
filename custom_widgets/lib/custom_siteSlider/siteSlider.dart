import 'package:custom_widgets/constants.dart';
import 'package:flutter/material.dart';

class SiteSlider extends StatefulWidget {
  final List<String> items;
  final Function(int)? select;
  final int? preSelectedIndex;

  const SiteSlider({
    required this.items,
    this.select,
    this.preSelectedIndex,
    super.key,
  });

  @override
  SiteSliderState createState() => SiteSliderState();
}

class SiteSliderState extends State<SiteSlider> {
  // Variables
  int sliderSelection = 0;

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

    sliderSelection = widget.preSelectedIndex ?? 0;

    load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> load() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  // Functions
  void select(index) {
    if (widget.select != null && sliderSelection != index) {
      setState(() {
        sliderSelection = index;
      });
      widget.select!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: widget.items.asMap().entries.map(
          (entry) {
            int index = entry.key;
            String item = entry.value;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  select(index);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: sliderSelection == index
                        ? Border(
                            bottom: BorderSide(
                              color: constants.fontColor,
                              width: 2.0,
                            ),
                          )
                        : Border(
                            bottom: BorderSide(
                              color: constants.primary,
                              width: 2.0,
                            ),
                          ),
                  ),
                  child: Center(
                    child: Text(
                      item,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: constants.fontFamily,
                        fontSize: constants.regularFontSize,
                        color: sliderSelection == index ? constants.fontColor : constants.subFontColor,
                        fontWeight: constants.medium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}
