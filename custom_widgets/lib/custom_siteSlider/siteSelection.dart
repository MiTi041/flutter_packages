import 'package:custom_widgets/constants.dart';
import 'package:flutter/material.dart';

class SiteSelection extends StatefulWidget {
  final List<String> items;
  final Function(int)? select;
  final int? preSelectedIndex;

  const SiteSelection({
    required this.items,
    this.select,
    this.preSelectedIndex,
    super.key,
  });

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
      clipBehavior: Clip.none,
      decoration: const BoxDecoration(),
      margin: const EdgeInsets.only(bottom: 15),
      width: constants.size.width,
      height: 35,
      child: CustomScrollView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        //controller: scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: widget.items.asMap().entries.map(
                (entry) {
                  int index = entry.key;
                  String item = entry.value;
                  return GestureDetector(
                    onTap: () {
                      select(index);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: sliderSelection == index ? constants.blue.withValues(alpha: 0.2) : constants.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontFamily: constants.fontFamily,
                            fontSize: constants.regularFontSize,
                            color: sliderSelection == index ? constants.fontColor : constants.subFontColor,
                            fontWeight: constants.medium,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
