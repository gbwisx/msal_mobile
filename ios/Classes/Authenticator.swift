//
//  Authenticator.swift
//  Runner
//
//  Created by Greg Burke on 12/27/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation
import MSAL

class Authenticator {
    private var client : MSALPublicClientApplication
    private var webViewParameters : MSALWebviewParameters
    private var viewController : UIViewController
    
    init(viewController : UIViewController?, configFilePath: String, authorityURL: String) throws {
        guard let MSALAuthorityURL = URL(string: authorityURL) else { throw MsalMobileException(code: "no_authority", message: "No authority was provided.") }
        guard let vc = viewController else { throw MsalMobileException(code: "no_view_controller", message: "No view controller was provided.") }
        
        self.viewController = vc
        self.webViewParameters = MSALWebviewParameters(parentViewController: vc)
        
        // get some settings from the auth config file (like client id)
        var clientId:String = ""
        var redirectUri:String = ""
        let jsonObject = try? JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: configFilePath)), options: [])
        if let dictionary = jsonObject as? [String: Any] {
            clientId = dictionary["client_id"] as! String
            if dictionary.index(forKey: "ios_redirect_uri") != nil {
                redirectUri = dictionary["ios_redirect_uri"] as! String
            } else if let bundleId = Bundle.main.bundleIdentifier {
                redirectUri = "msauth." + bundleId + "://auth"
            }
        }
        
        let authority = try MSALAADAuthority.init(url: MSALAuthorityURL)
        
        let config = MSALPublicClientApplicationConfig(clientId: clientId, redirectUri: redirectUri, authority: authority)
        client = try MSALPublicClientApplication.init(configuration: config)
    }
    
    public func getAccount() throws -> MSALAccount? {
        // We retrieve our current account by getting the first account from cache
        // In multi-account applications, account should be retrieved by home account identifier or username instead

        let cachedAccounts = try client.allAccounts()
        if !cachedAccounts.isEmpty {
            return cachedAccounts.first
        }
        
        return nil
    }
    
    public func signIn(scopes: [String], completionBlock: @escaping MSALCompletionBlock) {
        // this call doesn't really exist the same as it does for Android, so we'll just acquire a token interactively
        acquireToken(scopes: scopes, completionBlock: completionBlock)
    }
    
    public func signOut() throws {
        if let currentAccount = try getAccount() {
            try client.remove(currentAccount)
        }
    }
    
    public func acquireToken(scopes: [String], completionBlock: @escaping MSALCompletionBlock) {
        let parameters = MSALInteractiveTokenParameters(scopes: scopes, webviewParameters: webViewParameters)
        client.acquireToken(with: parameters, completionBlock: completionBlock)
    }
    
    public func acquireTokenSilent(scopes: [String], completionBlock: @escaping MSALCompletionBlock) throws {
        if let currentAccount = try getAccount() {
            let parameters = MSALSilentTokenParameters(scopes: scopes, account: currentAccount)
            client.acquireTokenSilent(with: parameters, completionBlock: completionBlock)
        }
    }
}
