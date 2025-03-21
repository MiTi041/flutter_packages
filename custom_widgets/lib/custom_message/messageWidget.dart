import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:custom_widgets/custom_button/button.dart';
import 'package:custom_widgets/constants.dart';

class MessageWidget extends StatefulWidget {
  final String? titel;
  final String? text;
  final Image? image;
  final IconData? icon;
  final String buttonText;
  final String? closeButton;
  final Color? fontColor;
  final bool isTooltip;
  final List<Widget>? items;
  final Color? closeButtonColor;
  final Color? iconColor;

  final VoidCallback? click;
  final VoidCallback? close;
  final VoidCallback? outerTap;

  const MessageWidget({
    required this.titel,
    required this.text,
    this.icon,
    this.image,
    required this.buttonText,
    this.isTooltip = false,
    this.click,
    this.close,
    this.outerTap,
    this.fontColor,
    this.closeButton,
    this.items,
    this.closeButtonColor,
    this.iconColor,
    super.key,
  });

  @override
  MessageWidgetState createState() => MessageWidgetState();
}

class MessageWidgetState extends State<MessageWidget> {
  // Variables

  // Instances
  final ScrollController scrollController = ScrollController();

  // Standard
  @override
  void initState() {
    super.initState();
    load();
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
    final size = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (widget.outerTap != null) widget.outerTap!();
          },
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: Container(decoration: BoxDecoration(color: constants.background.withValues(alpha: 0.4)))),
              ),
              Container(height: size.height, width: size.width, decoration: const BoxDecoration(color: Colors.transparent)),
            ],
          ),
        ),
        Center(
          child: SafeArea(
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.all(50),
                width: MediaQuery.of(context).size.width,
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
                child: Container(
                  decoration: BoxDecoration(color: constants.background, borderRadius: BorderRadius.circular(20), border: Border.all(color: constants.primary)),
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Gap(10),
                      widget.isTooltip
                          ? Container(height: 80, constraints: const BoxConstraints(maxWidth: double.infinity), child: widget.image)
                          : (widget.icon != null || widget.image != null)
                              ? Container(
                                  height: 48,
                                  width: 48,
                                  decoration: BoxDecoration(color: constants.fontColor, borderRadius: BorderRadius.circular(50)),
                                  child: Center(
                                    child: widget.icon == null
                                        ? SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: widget.image,
                                          )
                                        : Icon(
                                            widget.icon,
                                            size: 25,
                                            color: widget.iconColor ?? constants.background,
                                          ),
                                  ),
                                )
                              : SizedBox(),
                      const Gap(15),
                      if (widget.titel != null) ...[
                        Text(
                          widget.titel!,
                          textAlign: TextAlign.center,
                          style: TextStyle(height: 1, fontFamily: constants.fontFamily, fontSize: constants.semibigFontSize, color: constants.fontColor, fontWeight: constants.bold),
                        ),
                        const Gap(5),
                      ],
                      if (widget.text != null)
                        Text(
                          widget.text!,
                          textAlign: TextAlign.center,
                          style: TextStyle(height: 1, fontFamily: constants.fontFamily, fontSize: constants.regularFontSize, color: constants.subFontColor, fontWeight: constants.medium),
                        ),
                      if (widget.items != null && widget.items!.isNotEmpty) Column(children: [const Gap(15), for (Widget item in widget.items!) item]),
                      const Gap(15),
                      Button(
                        text: widget.buttonText,
                        color: constants.secondary,
                        border: Border.all(color: constants.third, width: 1),
                        fontColor: widget.fontColor,
                        click: () {
                          if (widget.click != null) widget.click!();
                        },
                      ),
                      widget.closeButton != null
                          ? Column(
                              children: [
                                const Gap(15),
                                GestureDetector(
                                  onTap: () {
                                    if (widget.close != null) widget.close!();
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(color: Colors.transparent),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            widget.closeButton!,
                                            style: TextStyle(
                                              height: 1,
                                              fontFamily: constants.fontFamily,
                                              fontSize: constants.mediumFontSize,
                                              color: widget.closeButtonColor ?? constants.fontColor,
                                              fontWeight: constants.medium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
