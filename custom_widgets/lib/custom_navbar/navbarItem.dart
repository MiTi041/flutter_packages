import 'package:custom_widgets/custom_frame/frame_provider.dart';
import 'package:flutter/material.dart';
import 'package:custom_widgets/constants.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class NavbarItem extends StatefulWidget {
  final IconData iconActive;
  final IconData? iconInactive;
  final String text;
  final Function()? click;
  bool isSelected;

  NavbarItem({
    required this.iconActive,
    this.iconInactive,
    required this.text,
    this.click,
    this.isSelected = false,
    super.key,
  });

  @override
  NavbarItemState createState() => NavbarItemState();
}

class NavbarItemState extends State<NavbarItem> {
  // Variables

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

  Future<void> load() async {}

  // Functions

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();
    final frameProvider = Provider.of<FrameProvider>(context, listen: true);

    IconData iconInactive = widget.iconInactive ?? widget.iconActive;

    return Column(
      children: [
        Icon(
          widget.isSelected ? widget.iconActive : iconInactive,
          size: 22,
          color: widget.isSelected ? constants.fontColor : constants.subFontColor,
        ),
        const Gap(1),
        Text(
          widget.text,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            height: 1.1,
            textBaseline: TextBaseline.alphabetic,
            fontFamily: constants.fontFamily,
            fontSize: constants.regularFontSize,
            color: widget.isSelected ? constants.fontColor : constants.subFontColor,
            fontWeight: widget.isSelected ? constants.bold : constants.regular,
          ),
        ),
      ],
    );
  }
}
