import 'package:custom_widgets/constants.dart';
import 'package:custom_widgets/custom_button/button.dart';
import 'package:custom_widgets/custom_emptyState/emptyState.dart';
import 'package:custom_widgets/custom_frame/frame.dart';
import 'package:flutter/cupertino.dart';
import 'package:local_auth/local_auth.dart';

class AuthGuard extends StatefulWidget {
  final Widget child;
  final bool disabled;

  const AuthGuard({
    super.key,
    required this.child,
    this.disabled = false,
  });

  @override
  AuthGuardState createState() => AuthGuardState();
}

class AuthGuardState extends State<AuthGuard> {
  // Variables
  bool isAuthenticated = false;
  bool isChecking = true;

  // Instances
  final LocalAuthentication auth = LocalAuthentication();

  // Standard
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (!widget.disabled) authenticateUser();
  }

  // Functions
  Future<bool> authenticate() async {
    final bool canAuthenticate = await auth.canCheckBiometrics || await auth.isDeviceSupported();
    if (!canAuthenticate) return false;

    try {
      return await auth.authenticate(
        localizedReason: 'Bitte authentifizieren Sie sich mit Face ID.',
        options: const AuthenticationOptions(),
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> authenticateUser() async {
    setState(() {
      isChecking = true;
    });
    bool success = await authenticate();
    if (success) {
      setState(() {
        isAuthenticated = true;
        isChecking = false;
      });
    } else {
      setState(() {
        isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    Constants constants = Constants();

    if (widget.disabled) return widget.child;

    if (isChecking) {
      return Frame(
        neverScrollPhysics: true,
        widget: SizedBox(
          height: size.height,
          child: Center(
            child: CupertinoActivityIndicator(),
          ),
        ),
      );
    }

    if (!isAuthenticated) {
      return Frame(
        neverScrollPhysics: true,
        widget: SizedBox(
          height: size.height,
          child: Center(
            child: EmptyState(
                illustration: const Text('🚨', textAlign: TextAlign.center, style: TextStyle(fontSize: 50)),
                title: "Authentifizierung fehlgeschlagen",
                text: "Bitte authentifiziere dich erneut",
                button: [
                  Button(
                    text: 'Erneut versuchen',
                    color: constants.blue,
                    click: () {
                      authenticateUser();
                    },
                  ),
                ]),
          ),
        ),
      );
    }

    return widget.child;
  }
}
