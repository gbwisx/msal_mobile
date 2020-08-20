import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'exception.dart';
import 'payload.dart';
import 'result.dart';

export 'account.dart';
export 'exception.dart';
export 'payload.dart';

class MsalMobile {
  static const MethodChannel _channel =
      const MethodChannel('com.gbwisx.msal_mobile');
  static bool initialized = false;

  /// Creates a new MsalMobile client object to make calls to the MSAL library.
  /// The signed in status is updated as a result of this call.
  static Future<MsalMobile> create(
      String configFilePath, String authority) async {
    if (initialized) {
      throw MsalMobileException.fromErrorCode(
          MsalMobileExceptionErrorCode.alreadyInitialized);
    }

//    String cacheFilePath;
    if (configFilePath == null || configFilePath.length < 1) {
      throw MsalMobileException.fromErrorCode(
          MsalMobileExceptionErrorCode.configRequired);
    }
//    try {
//      cacheFilePath = await cacheConfigFile(configFilePath);
//    } on Exception catch (ex) {
//      throw MsalMobileException.fromErrorCodeWithInner(
//          MsalMobileExceptionErrorCode.configReadError, ex);
//    }

    final response = await _channel.invokeMethod<String>(
        'init', <String, dynamic>{
      'configFilePath': configFilePath,
      'authority': authority
    });
    final result = response != null
        ? MsalMobileResult.fromJson(jsonDecode(response))
        : null;
    if (!result.isSuccess && result.exception != null) {
      throw MsalMobileException.copy(result.exception, result.innerException);
    }
    initialized = true;
    final client = MsalMobile();
    return client;
  }

  /// Caches the auth configuration file so it can be accessed by the platform specific MSAL implementations.
  static Future<String> cacheConfigFile(String configPath) async {
    final ByteData data = await rootBundle.load(configPath);
    final file = await DefaultCacheManager()
        .putFile(configPath, data.buffer.asUint8List());
    return file.path;
  }

  /// Gets the current signed in status.  If a current account is specified by the MSAL library, then this is considered to be a signed in state.
  Future<bool> getSignedIn() async {
    if (!initialized) {
      throw MsalMobileException.fromErrorCode(
          MsalMobileExceptionErrorCode.notInitialized);
    }

    final accounts = await getAccount();
    return accounts != null && accounts.currentAccount != null;
  }

  /// Gets the current and prior account (if applicable) that was authenticated with MSAL.
  Future<MsalMobileGetAccountResultPayload> getAccount() async {
    if (!initialized) {
      throw MsalMobileException.fromErrorCode(
          MsalMobileExceptionErrorCode.notInitialized);
    }

    final response = await _channel.invokeMethod('getAccount');
    final result = response != null
        ? MsalMobileGetAccountResult.fromJson(jsonDecode(response))
        : null;
    if (!result.isSuccess && result.exception != null) {
      throw MsalMobileException.copy(result.exception, result.innerException);
    }
    return result.payload;
  }

  /// Signs a user into MSAL if there is not currently any user signed in.  This should be done prior to retrieving
  /// a token if there is no user currently signed in.
  Future<MsalMobileAuthenticationResultPayload> signIn(
      String loginHint, List<String> scopes) async {
    if (!initialized) {
      throw MsalMobileException.fromErrorCode(
          MsalMobileExceptionErrorCode.notInitialized);
    }

    final response = await _channel.invokeMethod(
      'signIn',
      <String, dynamic>{'loginHint': loginHint, 'scopes': scopes},
    );
    final result = response != null
        ? MsalMobileAuthenticationResult.fromJson(jsonDecode(response))
        : null;
    if (!result.isSuccess && result.exception != null) {
      // check if the user is already signed in.  That could be the cause of an invalid_parameter failure from MSAL
      final signedIn = await this.getSignedIn();
      if (signedIn) {
        throw MsalMobileException.fromErrorCode(
            MsalMobileExceptionErrorCode.alreadySignedIn);
      }
      throw MsalMobileException.copy(result.exception, result.innerException);
    }
    return result.payload;
  }

  /// Signs a user out of MSAL if there is currently a user signed in.
  Future<void> signOut() async {
    if (!initialized) {
      throw MsalMobileException.fromErrorCode(
          MsalMobileExceptionErrorCode.notInitialized);
    }

    final response = await _channel.invokeMethod('signOut');
    final result = response != null
        ? MsalMobileResult.fromJson(jsonDecode(response))
        : null;
    if (!result.isSuccess && result.exception != null) {
      throw MsalMobileException.copy(result.exception, result.innerException);
    }
  }

  /// Acquires a token interactively, using the necessary UI screens to facilitate the token acquisition.  This bypasses cached values.
  Future<MsalMobileAuthenticationResultPayload> acquireTokenInteractive(
      List<String> scopes) async {
    if (!initialized) {
      throw MsalMobileException.fromErrorCode(
          MsalMobileExceptionErrorCode.notInitialized);
    }

    final response = await _channel.invokeMethod(
      'acquireToken',
      <String, dynamic>{'scopes': scopes},
    );
    final result = response != null
        ? MsalMobileAuthenticationResult.fromJson(jsonDecode(response))
        : null;
    if (!result.isSuccess && result.exception != null) {
      throw MsalMobileException.copy(result.exception, result.innerException);
    }
    return result.payload;
  }

  /// Acquires a token silently (without UI).  An exception will be thrown if a token cannot be acquired silently.  A user must
  /// first be signed in to successfully retrieve a token silently.
  Future<MsalMobileAuthenticationResultPayload> acquireTokenSilent(
      List<String> scopes, String authority) async {
    if (!initialized) {
      throw MsalMobileException.fromErrorCode(
          MsalMobileExceptionErrorCode.notInitialized);
    }

    final response = await _channel.invokeMethod(
      'acquireTokenSilent',
      <String, dynamic>{'scopes': scopes, 'authority': authority},
    );
    final result = response != null
        ? MsalMobileAuthenticationResult.fromJson(jsonDecode(response))
        : null;
    if (!result.isSuccess && result.exception != null) {
      throw MsalMobileException.copy(result.exception, result.innerException);
    }
    return result.payload;
  }

  /// Attempts to acquire a token silently.  If silent token acquisition fails because the UI is required, then an attempt to acquire a token interactively will be made.
  Future<MsalMobileAuthenticationResultPayload> acquireToken(
      List<String> scopes, String authority) async {
    if (!initialized) {
      throw MsalMobileException.fromErrorCode(
          MsalMobileExceptionErrorCode.notInitialized);
    }

    final silentResponse = await _channel.invokeMethod(
      'acquireTokenSilent',
      <String, dynamic>{'scopes': scopes, 'authority': authority},
    );
    final silentResult = silentResponse != null
        ? MsalMobileAuthenticationResult.fromJson(jsonDecode(silentResponse))
        : null;
    if (!silentResult.isSuccess && silentResult.isUiRequired) {
      // acquire a token interactively
      final interactiveResponse = await _channel.invokeMethod(
        'acquireToken',
        <String, dynamic>{'scopes': scopes},
      );
      final interactiveResult = interactiveResponse != null
          ? MsalMobileAuthenticationResult.fromJson(
              jsonDecode(interactiveResponse))
          : null;
      if (!interactiveResult.isSuccess && interactiveResult.exception != null) {
        throw MsalMobileException.copy(
            interactiveResult.exception, interactiveResult.innerException);
      }
      return interactiveResult.payload;
    } else if (!silentResult.isSuccess && silentResult.exception != null) {
      throw MsalMobileException.copy(
          silentResult.exception, silentResult.innerException);
    }
    return silentResult.payload;
  }
}
