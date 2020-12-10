import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../exception/exception.dart';
import '../model/payload.dart';
import '../model/result.dart';

export '../exception/exception.dart';
export '../model/account.dart';
export '../model/payload.dart';

/// Should contain only one reference when create is called. Because native code does not support
/// multiple configurations. So, far now we will be creating a map size of 1 and save it.
/// If config changes, we remove previous reference and create a new one.
class MsalMobile {
  static final Map<String, IAuthenticator> _cache = <String, IAuthenticator>{};

  static IAuthenticator create(
      final String configFilePath, final String authority) {
    final String _cacheHash = "$configFilePath-$authority";
    if (!_cache.containsKey(_cacheHash)) {
      IAuthenticator _msalAuthenticatorInstance =
      _MicrosoftAuthenticator(configFilePath, authority);
      _cache.clear();
      _cache[_cacheHash] = _msalAuthenticatorInstance;
    }
    return _cache[_cacheHash];
  }
}

abstract class IAuthenticator {
  Future<bool> get isReady;

  /// Gets the current signed in status.  If a current account is specified by the MSAL library, then this is considered to be a signed in state.
  Future<bool> getSignedIn();

  /// Gets the current and prior account (if applicable) that was authenticated with MSAL.
  Future<MsalMobileGetAccountResultPayload> getAccount();

  /// Signs a user into MSAL if there is not currently any user signed in.  This should be done prior to retrieving
  /// a token if there is no user currently signed in.
  Future<MsalMobileAuthenticationResultPayload> signIn(
      String loginHint, List<String> scopes);

  /// Signs a user out of MSAL if there is currently a user signed in.
  Future<void> signOut();

  /// Acquires a token interactively, using the necessary UI screens to facilitate the token acquisition.  This bypasses cached values.
  Future<MsalMobileAuthenticationResultPayload> acquireTokenInteractive(
      List<String> scopes);

  /// Acquires a token silently (without UI).  An exception will be thrown if a token cannot be acquired silently.  A user must
  /// first be signed in to successfully retrieve a token silently.
  Future<MsalMobileAuthenticationResultPayload> acquireTokenSilent(
      List<String> scopes, String authority);

  /// Attempts to acquire a token silently.  If silent token acquisition fails because the UI is required, then an attempt to acquire a token interactively will be made.
  Future<MsalMobileAuthenticationResultPayload> acquireToken(
      List<String> scopes, String authority);

  Future<MsalMobileAuthenticationResultPayload> acquireTokenWithLoginHint(
      List<String> scopes, String authority, String loginHint);
}

class _MicrosoftAuthenticator implements IAuthenticator {
  static const MethodChannel _channel =
  const MethodChannel('com.gbwisx.msal_mobile');
  bool _initialized = false;
  Future<bool> _isPluginReady;

  @override
  Future<bool> get isReady => _isPluginReady;

  _MicrosoftAuthenticator(String tempConfigFilePath, String tempAuthority) {
    _isPluginReady = _init(tempConfigFilePath, tempAuthority);
  }

  Future<bool> _init(String configFilePath, String authority) async {
    String cacheFilePath;
    if (configFilePath == null || configFilePath.length < 1) {
      throw MsalMobileException.fromErrorCode(
          MsalMobileExceptionErrorCode.configRequired);
    }
    try {
      cacheFilePath = await _cacheConfigFile(configFilePath);
    } on Exception catch (ex) {
      throw MsalMobileException.fromErrorCodeWithInner(
          MsalMobileExceptionErrorCode.configReadError, ex);
    }

    final response = await _channel.invokeMethod<String>(
        'init', <String, dynamic>{
      'configFilePath': cacheFilePath,
      'authority': authority
    });
    final result = response != null
        ? MsalMobileResult.fromJson(jsonDecode(response))
        : null;
    if (!result.isSuccess && result.exception != null) {
      throw MsalMobileException.copy(result.exception, result.innerException);
    }
    _initialized = true;
    return _initialized;
  }

  /// Creates a new MsalMobile client object to make calls to the MSAL library.
  /// The signed in status is updated as a result of this call.

  /// Caches the auth configuration file so it can be accessed by the platform specific MSAL implementations.
  static Future<String> _cacheConfigFile(String configPath) async {
    final ByteData data = await rootBundle.load(configPath);
    final file = await DefaultCacheManager()
        .putFile(configPath, data.buffer.asUint8List());
    return file.path;
  }

  /// Gets the current signed in status.  If a current account is specified by the MSAL library, then this is considered to be a signed in state.
  @override
  Future<bool> getSignedIn() async {
    return _isPluginReady.then((_) async {
      final accounts = await getAccount();
      return accounts != null && accounts.currentAccount != null;
    });
  }

  /// Gets the current and prior account (if applicable) that was authenticated with MSAL.
  @override
  Future<MsalMobileGetAccountResultPayload> getAccount() async {
    return _isPluginReady.then((_) async {
      final response = await _channel.invokeMethod('getAccount');
      final result = response != null
          ? MsalMobileGetAccountResult.fromJson(jsonDecode(response))
          : null;
      if (!result.isSuccess && result.exception != null) {
        throw MsalMobileException.copy(result.exception, result.innerException);
      }
      return result.payload;
    });
  }

  /// Signs a user into MSAL if there is not currently any user signed in.  This should be done prior to retrieving
  /// a token if there is no user currently signed in.
  @override
  Future<MsalMobileAuthenticationResultPayload> signIn(
      String loginHint, List<String> scopes) async {
    return _isPluginReady.then((_) async {
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
    });
  }

  /// Signs a user out of MSAL if there is currently a user signed in.
  @override
  Future<void> signOut() async {
    return _isPluginReady.then((_) async {
      final response = await _channel.invokeMethod('signOut');
      final result = response != null
          ? MsalMobileResult.fromJson(jsonDecode(response))
          : null;
      if (!result.isSuccess && result.exception != null) {
        throw MsalMobileException.copy(result.exception, result.innerException);
      }
    });
  }

  /// Acquires a token interactively, using the necessary UI screens to facilitate the token acquisition.  This bypasses cached values.
  @override
  Future<MsalMobileAuthenticationResultPayload> acquireTokenInteractive(
      List<String> scopes) async {
    return _isPluginReady.then((_) async {
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
    });
  }

  /// Acquires a token silently (without UI).  An exception will be thrown if a token cannot be acquired silently.  A user must
  /// first be signed in to successfully retrieve a token silently.
  @override
  Future<MsalMobileAuthenticationResultPayload> acquireTokenSilent(
      List<String> scopes, String authority) async {
    return _isPluginReady.then((_) async {
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
    });
  }

  /// Attempts to acquire a token silently.  If silent token acquisition fails because the UI is required, then an attempt to acquire a token interactively will be made.
  @override
  Future<MsalMobileAuthenticationResultPayload> acquireToken(
      List<String> scopes, String authority) async {
    return _isPluginReady.then((_) async {
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
        if (!interactiveResult.isSuccess &&
            interactiveResult.exception != null) {
          throw MsalMobileException.copy(
              interactiveResult.exception, interactiveResult.innerException);
        }
        return interactiveResult.payload;
      } else if (!silentResult.isSuccess && silentResult.exception != null) {
        throw MsalMobileException.copy(
            silentResult.exception, silentResult.innerException);
      }
      return silentResult.payload;
    });
  }

  @override
  Future<MsalMobileAuthenticationResultPayload> acquireTokenWithLoginHint(
      List<String> scopes, String authority, String loginHint) async {
    return _isPluginReady.then((_) async {
      final silentResponse = await _channel.invokeMethod(
        'acquireTokenSilent',
        <String, dynamic>{'scopes': scopes, 'authority': authority},
      );
      final silentResult = silentResponse != null
          ? MsalMobileAuthenticationResult.fromJson(jsonDecode(silentResponse))
          : null;
      if (!silentResult.isSuccess && silentResult.isUiRequired) {

        Map<String, dynamic> params = {'scopes': scopes};
        if(loginHint != null){
          params['loginHint'] = loginHint;
        }
        // acquire a token interactively
        final interactiveResponse = await _channel.invokeMethod(
          'acquireTokenWithLoginHint',
          params,
        );
        final interactiveResult = interactiveResponse != null
            ? MsalMobileAuthenticationResult.fromJson(
            jsonDecode(interactiveResponse))
            : null;
        if (!interactiveResult.isSuccess &&
            interactiveResult.exception != null) {
          throw MsalMobileException.copy(
              interactiveResult.exception, interactiveResult.innerException);
        }
        return interactiveResult.payload;
      } else if (!silentResult.isSuccess && silentResult.exception != null) {
        throw MsalMobileException.copy(
            silentResult.exception, silentResult.innerException);
      }
      return silentResult.payload;
    });
  }
}
