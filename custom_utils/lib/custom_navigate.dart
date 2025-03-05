import 'package:flutter/cupertino.dart';

mixin class Navigate {
  void navigateToWithSlide(BuildContext context, Widget page, {VoidCallback? isPopped}) {
    Navigator.push(context, CupertinoPageRoute(maintainState: false, builder: (context) => page)).then((_) {
      if (isPopped != null) {
        isPopped(); // Call the callback function when the page is popped
      }
    });
  }

  void navigateToWithSlidePopPrevious(BuildContext context, Widget page, {VoidCallback? isPopped}) {
    Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(maintainState: false, builder: (context) => page), (route) => false).then((_) {
      if (isPopped != null) {
        isPopped();
      }
    });
  }
}
