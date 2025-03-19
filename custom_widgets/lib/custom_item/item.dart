import 'package:custom_utils/custom_vibrate.dart';
import 'package:custom_widgets/constants.dart';
import 'package:custom_widgets/custom_clickAnimationWrap.dart/clickAnimationWrap.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Item extends StatefulWidget {
  final String titel;
  final List<Widget> content;
  final Constants? constants;
  final Border? border;
  final Function()? click;
  final Function()? longPress;

  const Item({this.titel = "", required this.content, this.constants, this.border, this.click, this.longPress, super.key});

  @override
  ItemState createState() => ItemState();
}

class ItemState extends State<Item> with SingleTickerProviderStateMixin, Vibrate {
  // Variables
  late Constants constants;

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

    if (widget.constants == null) {
      constants = Constants();
    } else {
      constants = widget.constants!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      load();
    });
  }

  Future<void> load() async {}

  // Functions

  @override
  Widget build(BuildContext context) {
    return ClickAnimationWrap(
      disabled: widget.click == null && widget.longPress == null,
      onTap: (widget.click == null) ? null : () => widget.click!(),
      onLongPress: (widget.longPress == null) ? null : () => widget.longPress!(),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: constants.primary,
              borderRadius: BorderRadius.circular(12),
              border: widget.border ??
                  Border.all(
                    color: constants.secondary,
                    width: 0.5,
                  ),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.titel != "") ...[
                  Text(
                    widget.titel,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      height: 1,
                      fontFamily: constants.fontFamily,
                      fontSize: constants.semibigFontSize,
                      color: constants.fontColor,
                      fontWeight: constants.bold,
                    ),
                  ),
                  const Gap(10),
                ],
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.content,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
