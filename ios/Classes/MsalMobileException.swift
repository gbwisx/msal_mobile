//
//  MsalMobileException.swift
//  FMDB
//
//  Created by Greg Burke on 12/28/19.
//

import Foundation

class MsalMobileException : Error {
    private var errorCode : String
    private var message : String
    
    init(code : String, message: String) {
        self.message = message
        errorCode = code
    }
}
