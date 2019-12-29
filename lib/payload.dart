import 'package:msal_mobile/account.dart';

class MsalMobileResultPayload {}

class MsalMobileGetAccountResultPayload extends MsalMobileResultPayload {
  final MsalMobileAccount currentAccount;
  final bool accountLoaded;

  MsalMobileGetAccountResultPayload.fromJson(Map<String, dynamic> json)
      : currentAccount = json['currentAccount'] != null
            ? MsalMobileAccount.fromJson(
                json['currentAccount'] as Map<String, dynamic>)
            : null,
        accountLoaded = json['accountLoaded'];
}

class MsalMobileAuthenticationResultPayload extends MsalMobileResultPayload {
  final bool cancelled;
  final bool success;
  final String accessToken;
  final String tenantId;
  final List<dynamic> scope;
  final String expiresOn;

  MsalMobileAuthenticationResultPayload.fromJson(Map<String, dynamic> json)
      : cancelled = json['cancelled'],
        success = json['success'],
        accessToken = json['accessToken'],
        tenantId = json['tenantId'],
        scope = json['scope'] != null
            ? json['scope'] as List<dynamic>
            : List<dynamic>(),
        expiresOn = json['expiresOn'] != null ? json['expiresOn'] : null;
}
