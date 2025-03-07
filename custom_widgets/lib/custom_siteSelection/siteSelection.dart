import 'package:custom_utils/custom_vibrate.dart';
import 'package:custom_widgets/constants.dart';
import 'package:custom_widgets/custom_siteSelection/siteSelectionItem.dart';
import 'package:flutter/cupertino.dart';

class SiteSelection extends StatefulWidget {
  final List<SiteSelectionItem> items;
  final Function(int)? select;
  final int? preSelectedIndex;

  const SiteSelection({
    required this.items,
    this.select,
    this.preSelectedIndex,
    super.key,
  }) : assert(items.length > 0 && items.length < 7);

  @override
  SiteSelectionState createState() => SiteSelectionState();
}

class SiteSelectionState extends State<SiteSelection> {
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      load();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> load() async {}

  // Functions
  void select(index) {
    Vibrate().vibrateLight();
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
      clipBehavior: Clip.none,
      decoration: const BoxDecoration(),
      width: constants.size.width,
      height: 40,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: widget.items.asMap().entries.map((entry) {
          int index = entry.key;
          SiteSelectionItem item = entry.value;

          return GestureDetector(
            onTap: () {
              select(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              width: sliderSelection == index ? calculateWidth(widget.items.length) : 47,
              margin: EdgeInsets.only(right: entry.key == widget.items.length - 1 ? 0 : 5),
              padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
              decoration: BoxDecoration(color: sliderSelection == index ? item.color ?? constants.blue : constants.secondary, borderRadius: BorderRadius.circular(15)),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(sliderSelection == index ? item.iconActive : item.iconInactive, size: 17, color: sliderSelection == index ? constants.fontColor : constants.subFontColor),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.fastOutSlowIn,
                      width: sliderSelection == index ? calculateTextWidth(item.text) : 0,
                      margin: EdgeInsets.only(left: sliderSelection == index ? 5 : 0),
                      child: Text(
                        item.text,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: constants.fontFamily,
                          fontSize: constants.semibigFontSize,
                          height: 1,
                          color: sliderSelection == index ? constants.fontColor : constants.subFontColor,
                          fontWeight: constants.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  double calculateTextWidth(String text) {
    final Constants constants = Constants();
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontFamily: constants.fontFamily, fontSize: constants.semibigFontSize, fontWeight: constants.bold)),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width + 5;
  }

  double calculateWidth(int length) {
    final Constants constants = Constants();
    return ((constants.size.width - 30) - (length - 1) * 52);
  }
}
