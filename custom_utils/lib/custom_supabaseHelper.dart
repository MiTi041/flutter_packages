import 'dart:convert';
import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';

mixin SupabaseHelper {
  /// Zugriff auf den Supabase-Client nur, wenn initialisiert.
  SupabaseClient get supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      throw Exception(
        'Supabase wurde noch nicht initialisiert. '
        'Bitte rufe SupabaseHelper.initialize() in main() auf.',
      );
    }
  }

  /// Initialisiert Supabase (muss in main.dart einmalig aufgerufen werden)
  static Future<void> initialize({required String url, required String anonKey}) async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  User? getUser() {
    try {
      return supabase.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Echtzeit-Listener für Änderungen in einer beliebigen Tabelle
  void listenToTableUpdates({required String table, required List<String> primaryKey, required Function(List<Map<String, dynamic>>) onUpdate}) {
    try {
      supabase.from(table).stream(primaryKey: primaryKey).listen((data) {
        onUpdate(data.cast<Map<String, dynamic>>());
      });
    } catch (e) {
      log('Fehler beim Starten des Echtzeit-Listeners: $e');
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      final response = await supabase.auth.signUp(email: email, password: password);
      return response.user != null;
    } catch (e) {
      log('Fehler bei der Registrierung: $e');
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(email: email, password: password);
      return response.user != null;
    } catch (e) {
      log('Fehler beim Login: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      log('Fehler beim Logout: $e');
    }
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
