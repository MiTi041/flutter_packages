import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:custom_widgets/constants.dart';

class CustomBanner extends StatefulWidget {
  final String titel;
  final String text;
  final String? buttonText;
  final String? closeButtonText;
  final Constants? constants;

  final VoidCallback? click;

  const CustomBanner({required this.titel, required this.text, this.buttonText, this.closeButtonText, this.click, this.constants, super.key});

  @override
  CustomBannerState createState() => CustomBannerState();
}

class CustomBannerState extends State<CustomBanner> {
  // Variables
  bool isVisible = true;
  late Constants constants;

  // Instances

  // Standard
  @override
  void initState() {
    super.initState();

    if (widget.constants == null) {
      constants = Constants();
    } else {
      constants = widget.constants!;
    }

    load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> load() async {}

  // Functions
  void close() {
    setState(() {
      isVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isVisible
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [constants.primary, constants.blue.withValues(alpha: 0.2)], begin: Alignment.bottomLeft, end: Alignment.topRight),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.titel,
                            softWrap: true,
                            maxLines: null,
                            style: TextStyle(height: 1, fontFamily: constants.fontFamily, fontSize: constants.semibigFontSize, color: constants.fontColor, fontWeight: constants.bold),
                          ),
                          const Gap(5),
                          Text(
                            widget.text,
                            softWrap: true,
                            maxLines: null,
                            style: TextStyle(height: 1, fontFamily: constants.fontFamily, fontSize: constants.regularFontSize, color: constants.subFontColor, fontWeight: constants.medium),
                          ),
                          if (widget.buttonText != null || widget.closeButtonText != null)
                            Column(
                              children: [
                                const Gap(15),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (widget.buttonText != null)
                                      GestureDetector(
                                        onTap: () => widget.click!(),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: constants.blue, borderRadius: BorderRadius.circular(50)),
                                          child: Text(
                                            widget.buttonText!,
                                            style:
                                                TextStyle(height: 1, fontFamily: constants.fontFamily, fontSize: constants.regularFontSize, color: constants.fontColor, fontWeight: constants.medium),
                                          ),
                                        ),
                                      ),
                                    if (widget.buttonText != null && widget.closeButtonText != null) const Gap(5),
                                    if (widget.closeButtonText != null)
                                      GestureDetector(
                                        onTap: () => close(),
                                        child: Container(
                                          decoration: const BoxDecoration(color: Colors.transparent),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            child: Text(
                                              widget.closeButtonText!,
                                              style: TextStyle(
                                                height: 1,
                                                fontFamily: constants.fontFamily,
                                                fontSize: constants.regularFontSize,
                                                color: constants.fontColor,
                                                fontWeight: constants.medium,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => close(),
                      child: Container(
                        height: 20,
                        width: 20,
                        decoration: const BoxDecoration(color: Colors.transparent),
                        child: Center(child: SizedBox(height: 10, child: Image.asset('${constants.imgPath}cross.png'))),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        : Container();
  }
}
