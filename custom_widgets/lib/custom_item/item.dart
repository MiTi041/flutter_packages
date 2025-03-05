import 'package:custom_widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Item extends StatefulWidget {
  final String titel;
  final List<Widget> content;
  final Constants? constants;

  const Item({this.titel = "", required this.content, this.constants, super.key});

  @override
  ItemState createState() => ItemState();
}

class ItemState extends State<Item> {
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

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> load() async {}

  // Functions

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(color: constants.primary, borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.titel != "") ...[
                Text(
                  widget.titel,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: constants.fontFamily, fontSize: constants.semibigFontSize, color: constants.fontColor, fontWeight: constants.bold),
                ),
                const Gap(10),
              ],
              Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: widget.content),
            ],
          ),
        ),
      ],
    );
  }
}
