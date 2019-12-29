//
//  Payloads.swift
//  msal_mobile
//
//  Created by Greg Burke on 12/28/19.
//

import Foundation
import MSAL

class MsalMobileResultPayload : Codable {
    private var currentAccount : Account?
    private var accountLoaded : Bool
    
    private var cancelled : Bool
    private var success : Bool
    private var accessToken : String?
    private var tenantId : String?
    private var scope : [String]
    private var expiresOn : String?
    
    init() {
        cancelled = false
        success = true
        accessToken = nil
        tenantId = nil
        scope = []
        expiresOn = nil
        
        currentAccount = nil
        accountLoaded = false
    }
    
    init(authSuccessful : Bool, authCancelled : Bool, authAccessToken : String?) {
        self.success = authSuccessful
        self.cancelled = authCancelled
        self.accessToken = authAccessToken
        self.tenantId = nil
        self.scope = []
        self.expiresOn = nil
        
        self.currentAccount = nil
        self.accountLoaded = false
    }
    
    init(msalResult : MSALResult) {
        self.cancelled = false
        self.success = true
        self.accessToken = msalResult.accessToken
        self.tenantId = msalResult.tenantProfile.tenantId
        self.scope = msalResult.scopes
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.expiresOn = dateFormatterPrint.string(from: msalResult.expiresOn)
        
        self.currentAccount = nil
        self.accountLoaded = false
    }
    
    init(currentMsalAccount : MSALAccount) {
        self.accountLoaded = true
        self.currentAccount = Account(msalAccount: currentMsalAccount)
        
        self.cancelled = false
        self.success = true
        self.accessToken = nil
        self.tenantId = nil
        self.scope = []
        self.expiresOn = nil
    }
}

class Account : Codable {
    private var tenantId : String?
    private var claims : [String : String]?
    private var authority : String?
    private var id : String?
    private var username : String?
    
    init(msalAccount : MSALAccount) {
        let info = msalAccount.homeAccountId

        tenantId = info?.tenantId
        claims = flattenClaims(msalClaims: msalAccount.accountClaims)
        authority = nil // not available
        id = msalAccount.identifier
        username = msalAccount.identifier
    }
    
    private func flattenClaims(msalClaims: [String: Any]?) -> [String: String]? {
        if let claims = self.claims {
            return Dictionary(uniqueKeysWithValues: claims.map { key, value in (key, value as String) })
        }
        return nil
    }
}
