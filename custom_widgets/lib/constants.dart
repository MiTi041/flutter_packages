import 'package:flutter/material.dart';

class Constants {
  static Constants? _instance;

  factory Constants({
    String? fontFamily,
    double? bigFontSize,
    double? semibigFontSize,
    double? mediumFontSize,
    double? regularFontSize,
    FontWeight? bold,
    FontWeight? semi,
    FontWeight? medium,
    FontWeight? regular,
    Color? green,
    Color? red,
    Color? blue,
    Color? orange,
    Color? pink,
    Color? yellow,
    Color? darkgreen,
    Color? background,
    Color? primary,
    Color? secondary,
    Color? third,
    Color? accent,
    Color? fontColor,
    Color? subFontColor,
    String? imgPath,
  }) {
    _instance ??= Constants._internal(
      fontFamily: fontFamily ?? "TripSans",
      bigFontSize: bigFontSize ?? 18,
      semibigFontSize: semibigFontSize ?? 14,
      mediumFontSize: mediumFontSize ?? 12,
      regularFontSize: regularFontSize ?? 10,
      bold: bold ?? FontWeight.w800,
      semi: semi ?? FontWeight.w600,
      medium: medium ?? FontWeight.w500,
      regular: regular ?? FontWeight.w400,
      green: green ?? const Color(0xFF53D377),
      red: red ?? const Color(0xFFD35353),
      blue: blue ?? const Color(0xFF2D64E3),
      orange: orange ?? const Color(0xFFD37253),
      pink: pink ?? const Color(0xFF8E0446),
      yellow: yellow ?? const Color(0xFFEAE33E),
      darkgreen: darkgreen ?? const Color(0xFF3D7E4B),
      background: background ?? const Color(0xFF121212),
      primary: primary ?? const Color(0xFF202020),
      secondary: secondary ?? const Color(0xFF293138),
      third: third ?? const Color(0xFF35424E),
      accent: accent ?? const Color(0xFFd5eb24),
      fontColor: fontColor ?? const Color(0xFFE0E6ED),
      subFontColor: subFontColor ?? const Color(0xFF83909D),
      imgPath: imgPath ?? "assets/icons/",
    );

    return _instance!;
  }

  Constants._internal({
    required this.fontFamily,
    required this.bigFontSize,
    required this.semibigFontSize,
    required this.mediumFontSize,
    required this.regularFontSize,
    required this.bold,
    required this.semi,
    required this.medium,
    required this.regular,
    required this.green,
    required this.red,
    required this.blue,
    required this.orange,
    required this.pink,
    required this.yellow,
    required this.darkgreen,
    required this.background,
    required this.primary,
    required this.secondary,
    required this.third,
    required this.accent,
    required this.fontColor,
    required this.subFontColor,
    required this.imgPath,
  });

  final String fontFamily;
  final double bigFontSize;
  final double semibigFontSize;
  final double mediumFontSize;
  final double regularFontSize;

  final FontWeight bold;
  final FontWeight semi;
  final FontWeight medium;
  final FontWeight regular;

  final Color green;
  final Color red;
  final Color blue;
  final Color orange;
  final Color pink;
  final Color yellow;
  final Color darkgreen;

  final Color background;
  final Color primary;
  final Color secondary;
  final Color third;
  final Color accent;

  final Color fontColor;
  final Color subFontColor;

  final String imgPath;

  final size = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

  static Size get screenSize {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    return view.physicalSize / view.devicePixelRatio;
  }
}
