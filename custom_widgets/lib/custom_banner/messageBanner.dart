import 'package:custom_widgets/custom_button/button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:custom_widgets/constants.dart';

enum MessageType { info, error, success, warning }

class MessageBanner extends StatelessWidget {
  final String text;
  final MessageType type;
  final VoidCallback? close;
  final Button? button;
  final bool shrink;
  final IconData? icon;

  const MessageBanner({
    required this.text,
    this.type = MessageType.info,
    this.close,
    this.button,
    this.shrink = false,
    this.icon,
    super.key,
  });

  Color _getBannerColor(Constants constants) {
    switch (type) {
      case MessageType.error:
        return constants.red.withValues(alpha: 0.2);
      case MessageType.success:
        return constants.green.withValues(alpha: 0.2);
      case MessageType.warning:
        return constants.orange.withValues(alpha: 0.2);
      case MessageType.info:
        return constants.blue.withValues(alpha: 0.2);
    }
  }

  IconData _getBannerIcon() {
    switch (type) {
      case MessageType.error:
        return CupertinoIcons.xmark;
      case MessageType.success:
        return CupertinoIcons.checkmark;
      case MessageType.warning:
        return CupertinoIcons.exclamationmark_triangle_fill;
      case MessageType.info:
        return CupertinoIcons.exclamationmark;
    }
  }

  Color _getTextColor(Constants constants) {
    switch (type) {
      case MessageType.error:
        return constants.red;
      case MessageType.success:
        return constants.green;
      case MessageType.warning:
        return constants.orange;
      case MessageType.info:
        return constants.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Constants constants = Constants();
    final size = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

    return Container(
      width: shrink ? null : double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: _getBannerColor(constants), borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Row(
            mainAxisSize: shrink ? MainAxisSize.min : MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _getBannerColor(constants),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  icon ?? _getBannerIcon(),
                  size: 12,
                  color: _getTextColor(constants),
                ),
              ),
              const Gap(10),
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    height: 1,
                    fontFamily: constants.fontFamily,
                    fontSize: constants.mediumFontSize,
                    color: _getTextColor(constants),
                    fontWeight: constants.semi,
                  ),
                ),
              ),
              const Gap(5),
              if (close != null) ...[
                const Gap(10),
                IconButton(
                  icon: Icon(Icons.close, color: _getTextColor(constants)),
                  onPressed: close,
                )
              ],
            ],
          ),
          if (button != null) ...[
            const Gap(10),
            button!,
          ],
        ],
      ),
    );
  }
}
