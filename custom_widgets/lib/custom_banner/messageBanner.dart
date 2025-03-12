import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:custom_widgets/constants.dart';

enum MessageType { info, error, success, warning }

class MessageBanner extends StatefulWidget {
  final String text;
  final MessageType type;
  final VoidCallback? close;

  const MessageBanner({required this.text, this.type = MessageType.info, this.close, super.key});

  @override
  MessageBannerState createState() => MessageBannerState();
}

class MessageBannerState extends State<MessageBanner> {
  // Instances
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Color _getBannerColor(Constants constants) {
    switch (widget.type) {
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

  String _getBannerIcon() {
    switch (widget.type) {
      case MessageType.error:
        return 'assets/icons/error.png';
      case MessageType.success:
        return 'assets/icons/checked.png';
      case MessageType.warning:
        return 'assets/icons/notChecked.png';
      case MessageType.info:
        return 'assets/icons/info.png';
    }
  }

  Color _getTextColor(Constants constants) {
    switch (widget.type) {
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
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: _getBannerColor(constants), borderRadius: BorderRadius.circular(15)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(_getBannerIcon(), height: 20),
          const Gap(5),
          Flexible(
            child: Text(widget.text, style: TextStyle(height: 1, fontFamily: constants.fontFamily, fontSize: constants.regularFontSize, color: _getTextColor(constants), fontWeight: constants.medium)),
          ),
          if (widget.close != null) ...[const Gap(10), IconButton(icon: Icon(Icons.close, color: _getTextColor(constants)), onPressed: widget.close)],
        ],
      ),
    );
  }
}
