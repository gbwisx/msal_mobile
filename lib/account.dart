import 'dart:collection';

class MsalMobileAccount {
  final String? tenantId;
  final String? authority;
  final String? id;
  final String? username;
  final HashMap<String, dynamic> claims;

  MsalMobileAccount.fromJson(Map<String, dynamic> json)
      : tenantId = json['tenantId'],
        authority = json['authority'],
        id = json['id'],
        username = json['username'],
        claims = json['claims'] != null
            ? HashMap<String, dynamic>.from(json['claims'])
            : HashMap<String, dynamic>();
}
