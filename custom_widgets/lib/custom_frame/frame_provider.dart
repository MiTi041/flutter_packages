import 'package:flutter/material.dart';

class FrameProvider with ChangeNotifier {
  static final FrameProvider singleton = FrameProvider.internal();

  factory FrameProvider() {
    return singleton;
  }

  FrameProvider.internal();

  int navIndex = 0;

  void changeIndex(index) {
    navIndex = index;
    notifyListeners();
  }

  //appbarNavbarHeight
  double appbarHeight = 129.0; // normalerweise - muss angegeben werden dmit die erste seite weiß wie hoch die appbar ist
  bool isAppbarBlurred = false;
  double modalPopupAppbarHeight = 0.0;
  double bottombarHeight = 0.0;

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

  void refreshBottombarHeights(double bottombarHeight) {
    this.bottombarHeight = bottombarHeight;
    notifyListeners();
  }
}
