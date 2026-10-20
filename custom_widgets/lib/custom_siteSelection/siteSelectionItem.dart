import 'package:flutter/cupertino.dart';

class SiteSelectionItem {
  final String text;
  final IconData iconActive;
  final IconData iconInactive;
  final Color? color;
  final bool showIndicator;

  SiteSelectionItem({required this.text, required this.iconActive, required this.iconInactive, this.color, this.showIndicator = false});
}
