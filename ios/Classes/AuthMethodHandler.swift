//
//  AuthMethodHandler.swift
//  Runner
//
//  Created by Greg Burke on 12/27/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation
import Flutter
import MSAL

class AuthMethodHandler {
    static let SERIALIZATION_ERROR_CODE : String = "result_serialization_error"
    private var auth : Authenticator?
    private static var handler : AuthMethodHandler?
    private let viewController : UIViewController
    
    public static func getInstance(viewController : UIViewController) -> AuthMethodHandler? {
        if self.handler == nil {
            self.handler = AuthMethodHandler(viewController: viewController)
        }
        return self.handler
    }
    
    init(viewController : UIViewController) {
        self.auth = nil;
        self.viewController = viewController
    }
    
    private func error(result: FlutterResult, exception: NSError) {
        let response = MsalMobileResult(error: exception)
        do {
            let json = try response.toJson()
            result(json)
        } catch {
            result(FlutterError(code: AuthMethodHandler.SERIALIZATION_ERROR_CODE, message: "An error occurred while performing the operation, then an error occurred while attempting to serialize the result of the operation", details: nil))
        }
    }
    private func error(result: FlutterResult, errorCode: String, message: String) {
        let response = MsalMobileResult(exceptionDetail: ExceptionDetail(errorCode: errorCode, message: message))
        do {
            let json = try response.toJson()
            result(json)
        } catch {
            result(FlutterError(code: AuthMethodHandler.SERIALIZATION_ERROR_CODE, message: "An error occurred while performing the operation, then an error occurred while attempting to serialize the result of the operation", details: nil))
        }
    }
    private func uiRequiredError(result: FlutterResult, exception: NSError) {
        let response = MsalMobileResult(error: exception)
        response.isUiRequired = true
        do {
            let json = try response.toJson()
            result(json)
        } catch {
            result(FlutterError(code: AuthMethodHandler.SERIALIZATION_ERROR_CODE, message: "A UI required error was being returned, then an error occurred while attempting to serialize the result of the operation", details: nil))
        }
    }
    private func success(result: FlutterResult, payload: MsalMobileResultPayload) {
        let response = MsalMobileResult(successPayload: payload)
        do {
            let json = try response.toJson()
            result(json)
        } catch {
            result(FlutterError(code: AuthMethodHandler.SERIALIZATION_ERROR_CODE, message: "The operation was successful but an error occurred while attempting to serialize the result of the operation", details: nil))
        }
    }
    private func success(result: FlutterResult) {
        let response = MsalMobileResult(successPayload: MsalMobileResultPayload())
        do {
            let json = try response.toJson()
            result(json)
        } catch {
            result(FlutterError(code: AuthMethodHandler.SERIALIZATION_ERROR_CODE, message: "The operation was successful but an error occurred while attempting to serialize the result of the operation", details: nil))
        }
    }
    
    private func handleInit(result: FlutterResult, configFilePath: String, authority: String) throws {
        self.auth = try Authenticator(viewController: viewController, configFilePath: configFilePath, authorityURL: authority)
        success(result: result)
    }
    
    private func handleGetAccount(result: @escaping FlutterResult) throws {
        guard let auth = self.auth else { return }
        var payload : MsalMobileResultPayload
        if let account = try auth.getAccount() {
            payload = MsalMobileResultPayload(currentMsalAccount: account)
        } else {
            payload = MsalMobileResultPayload()
        }
        let response = MsalMobileResult(successPayload: payload as MsalMobileResultPayload)
        result(try response.toJson())
    }
    
    private func handleSignIn(result: @escaping FlutterResult, scopes: [String]) {
        self.handleAcquireToken(result: result, scopes: scopes)
    }
    
    private func handleSignOut(result: FlutterResult) throws {
        try auth?.signOut()
        success(result: result)
    }
    
    private func handleAcquireToken(result: @escaping FlutterResult, scopes: [String]) {
        auth?.acquireToken(scopes: scopes, completionBlock: { (msalResult, error) in
            if let error = error {
                let nsError = error as NSError
                self.error(result: result, exception: nsError)
                return
            }
            
            guard let msalResult = msalResult else {
                self.error(result: result, errorCode: "msal_result_empty", message: "No error occurred but MSAL result was unexpectedly empty.")
                return
            }
            
            self.success(result: result, payload: MsalMobileResultPayload(msalResult: msalResult))
        })
    }
    
    private func handleAcquireTokenSilent(result: @escaping FlutterResult, scopes: [String]) throws {
        try auth?.acquireTokenSilent(scopes: scopes, completionBlock: { (msalResult, error) in
            if let error = error {
                let nsError = error as NSError
                if (nsError.domain == MSALErrorDomain) {
                    if (nsError.code == MSALError.interactionRequired.rawValue) {
                        // UI is required. Return an error that states that
                        DispatchQueue.main.async {
                            self.uiRequiredError(result: result, exception: nsError)
                        }
                        return
                    }
                }
                self.error(result: result, exception: nsError)
                return
            }
            
            guard let msalResult = msalResult else {
                self.error(result: result, errorCode: "msal_result_empty", message: "No error occurred but MSAL result was unexpectedly empty.")
                return
            }
            
            self.success(result: result, payload: MsalMobileResultPayload(msalResult: msalResult))
        })
    }
    
    public func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void {
        do {
            switch (call.method) {
            case "init":
                let args = call.arguments! as! NSDictionary
                let configFilePath = args["configFilePath"] as! String
                let authority = args["authority"] as! String
                try handleInit(result: result, configFilePath: configFilePath, authority: authority);
                break;
            case "getAccount":
                try handleGetAccount(result: result);
                break;
            case "signIn":
                let args = call.arguments! as! NSDictionary
                let scopes = args["scopes"] as! [String]
                handleSignIn(result: result, scopes: scopes);
                break;
            case "signOut":
                try handleSignOut(result: result);
                break;
            case "acquireToken":
                let args = call.arguments! as! NSDictionary
                let scopes = args["scopes"] as! [String]
                handleAcquireToken(result: result, scopes: scopes);
                break;
            case "acquireTokenSilent":
                let args = call.arguments! as! NSDictionary
                let scopes = args["scopes"] as! [String]
                try handleAcquireTokenSilent(result: result, scopes: scopes);
                break;
            default:
                result(FlutterMethodNotImplemented);
            }
        } catch let exception as NSError {
            error(result: result, exception: exception)
        }
    }
}
