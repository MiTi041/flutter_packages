import 'package:flutter/material.dart';

class DesktopFrameProvider with ChangeNotifier {
  static final DesktopFrameProvider singleton = DesktopFrameProvider.internal();

  factory DesktopFrameProvider() {
    return singleton;
  }

  DesktopFrameProvider.internal();

  int navIndex = 0;

  void changeIndex(index) {
    navIndex = index;
    notifyListeners();
  }

  //appbarNavbarHeight
  double appbarHeight = 129.0; // normalerweise - muss angegeben werden damit die erste seite weiß wie hoch die appbar ist
  bool isAppbarBlurred = false;
  double modalPopupAppbarHeight = 0.0;
  double navbarWidth = 0.0;

  void refreshAppbarHeights(double appbarHeight) {
    this.appbarHeight = appbarHeight;
    notifyListeners();
  }

  void refreshIsAppbarBlurred(bool isAppbarBlurred) {
    this.isAppbarBlurred = isAppbarBlurred;
    notifyListeners();
  }

  void refreshModalPopupAppbarHeights(double modalPopupAppbarHeight) {
    this.modalPopupAppbarHeight = modalPopupAppbarHeight;
    notifyListeners();
  }

  void refreshNavbarWidths(double navbarWidth) {
    this.navbarWidth = navbarWidth;
    notifyListeners();
  }
}
