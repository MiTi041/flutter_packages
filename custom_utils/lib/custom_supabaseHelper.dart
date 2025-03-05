import 'dart:convert';
import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';

mixin class SupabaseHelper {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Initialisiert Supabase (muss in main.dart einmalig aufgerufen werden)
  static Future<void> initialize({required String url, required String anonKey}) async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  User? getUser() {
    return supabase.auth.currentUser;
  }

  /// Echtzeit-Listener für Änderungen in einer beliebigen Tabelle
  void listenToTableUpdates({required String table, required List<String> primaryKey, required Function(List<Map<String, dynamic>>) onUpdate}) {
    supabase.from(table).stream(primaryKey: primaryKey).listen((data) {
      onUpdate(data.cast<Map<String, dynamic>>());
    });
  }

  /// Benutzer mit E-Mail und Passwort registrieren
  Future<bool> signUp(String email, String password) async {
    try {
      final response = await supabase.auth.signUp(email: email, password: password);
      return response.user != null;
    } catch (e) {
      log('Fehler bei der Registrierung: $e');
      return false;
    }
  }

  /// Benutzeranmeldung
  Future<bool> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(email: email, password: password);
      return response.user != null;
    } catch (e) {
      log('Fehler beim Login: $e');
      return false;
    }
  }

  /// Benutzer abmelden
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<AuthResponse> signInWithApple() async {
    try {
      final rawNonce = supabase.auth.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName], nonce: hashedNonce);

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw const AuthException('Could not find ID Token from generated credential.');
      }

      final authResponse = await supabase.auth.signInWithIdToken(provider: OAuthProvider.apple, idToken: idToken, nonce: rawNonce);

      return authResponse;
    } on SignInWithAppleAuthorizationException catch (e) {
      log(e.message);
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
