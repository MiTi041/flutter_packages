import 'package:flutter/cupertino.dart';

class SiteSelectionItem {
  final String text;
  final IconData iconActive;
  final IconData iconInactive;
  final Color? color;

  SiteSelectionItem({required this.text, required this.iconActive, required this.iconInactive, this.color});
}
