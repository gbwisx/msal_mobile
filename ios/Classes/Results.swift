//
//  Results.swift
//  msal_mobile
//
//  Created by Greg Burke on 12/28/19.
//

import Foundation
import MSAL

class MsalMobileResult : Codable {
    private var isSuccess : Bool
    private var exception : ExceptionDetail?
    private var innerException : ExceptionDetail?
    private var payload : MsalMobileResultPayload?
    public var isUiRequired : Bool
    
    init(exceptionDetail : ExceptionDetail) {
        isSuccess = false
        exception = exceptionDetail
        innerException = nil
        payload = nil
        isUiRequired = false
    }
    
    init(error : Error) {
        isSuccess = false
        exception = ExceptionDetail(error: error)
        innerException = nil // TODO
        payload = nil
        isUiRequired = false
    }
    
    init(successPayload : MsalMobileResultPayload) {
        isSuccess = true
        exception = nil
        innerException = nil
        payload = successPayload
        isUiRequired = false
    }
    
    static func success(successPayload : MsalMobileResultPayload) throws -> String {
        let result = MsalMobileResult(successPayload: successPayload)
        return try result.toJson()
    }
    
    static func error(exception : Error) throws -> String {
        let result = MsalMobileResult(error: exception)
        return try result.toJson()
    }
    
    static func uiRequiredError(exception : Error) throws -> String {
        let result = MsalMobileResult(error: exception)
        result.isUiRequired = true
        return try result.toJson()
    }
    
    func toJson() throws -> String {
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(self)
        let json = String(data: jsonData, encoding: .utf8)
        return json ?? ""
    }
}

class ExceptionDetail : Codable {
    private var message : String
    private var errorCode : String
    
    init(errorCode: String, message: String) {
        self.message = message
        self.errorCode = errorCode
    }
    
    init(error : Error) {
        message = error.localizedDescription
        errorCode = "unknown"
    }
}
