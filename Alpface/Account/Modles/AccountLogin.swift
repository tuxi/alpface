//
//  AccountLogin.swift
//  Alpface
//
//  Created by swae on 2018/3/25.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

public enum ALPAccountLoginError: LocalizedError {
    case cannotExtractLoginStatus
    case statusNotPass(String?)
    case temporaryPasswordNeedsChange(String?)
    case needsOathTokenFor2FA(String?)
    case wrongPassword
    case wrongToken
    public var errorDescription: String? {
        switch self {
        case .cannotExtractLoginStatus:
            return "Could not extract login status"
        case .statusNotPass(let message?):
            return message
        case .temporaryPasswordNeedsChange(let message?):
            return message
        case .needsOathTokenFor2FA(let message?):
            return message
        case .wrongPassword:
            return "Invalid password"
        case .wrongToken:
            return "Invalid code"
        default:
            return "Unable to login: Reason unknown"
        }
    }
}


public typealias ALPAccountLoginResultBlock = (AccountLoginResult) -> Void

@objc(ALPAccountLoginResult)
public class AccountLoginResult: NSObject {
    @objc var status: String
    @objc var username: String
    @objc var message: String?
    @objc init(status: String, username: String, message: String?) {
        self.status = status
        self.username = username
        self.message = message
    }
}


@objc(ALPAccountLogin)
public class AccountLogin: NSObject {
    
}
