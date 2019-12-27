import 'package:flutter/foundation.dart';

class MsalMobileException implements Exception {
  final String type;
  final String message;
  final String errorCode;
  final MsalMobileException innerException;

  MsalMobileException({@required this.message, this.errorCode, this.type, this.innerException});

  MsalMobileException.fromErrorCode(MsalMobileExceptionErrorCode code)
      : type = null,
        message = code.message,
        errorCode = code.errorCode,
        innerException = null;

  MsalMobileException.fromErrorCodeWithInner(MsalMobileExceptionErrorCode code, Exception innerException)
      : type = null,
        message = code.message,
        errorCode = code.errorCode,
        innerException = innerException;

  MsalMobileException.copy(MsalMobileException exception, MsalMobileException innerException)
      : type = exception?.type,
        message = exception?.message,
        errorCode = exception?.errorCode,
        innerException = innerException;

  MsalMobileException.fromJson(Map<String, dynamic> json)
      : type = json['isSuccess'],
        message = json['message'],
        errorCode = json['errorCode'],
        innerException = null;
}

class MsalMobileExceptionErrorCode {
  // Android specific
  static MsalMobileExceptionErrorCode noActivity = MsalMobileExceptionErrorCode('no_activity', 'Android: no activity was found to bind MSAL to.');

  // Platform
  static MsalMobileExceptionErrorCode configReadError = MsalMobileExceptionErrorCode('config_read_error',
      'The auth config file could not be read by the platform. Please ensure that the config file exists and has been added to the pubspec.yaml.');

  // Dart
  static MsalMobileExceptionErrorCode alreadyInitialized =
      MsalMobileExceptionErrorCode('already_initialized', 'MsalMobile has already been initialized.');
  static MsalMobileExceptionErrorCode notInitialized = MsalMobileExceptionErrorCode(
      'not_initialized', 'MsalMobile has not been initialized. Create an instance of MsalMobile by call its static create() method.');
  static MsalMobileExceptionErrorCode configRequired = MsalMobileExceptionErrorCode('already_initialized',
      'An auth config JSON file is required. Please ensure that you have added an auth config and added it to your pubspec.yaml.');
  static MsalMobileExceptionErrorCode authorityRequired =
      MsalMobileExceptionErrorCode('already_initialized', 'An authority must be specified to acquire a token silently.');
  static MsalMobileExceptionErrorCode alreadySignedIn =
      MsalMobileExceptionErrorCode('already_signed_in', 'You are already signed in. Call one of the acquire token methods to get a token.');
  static MsalMobileExceptionErrorCode unknown = MsalMobileExceptionErrorCode('unknown', 'An unknown error occurred.');

  final String errorCode;
  final String message;

  MsalMobileExceptionErrorCode(this.errorCode, this.message);
}
