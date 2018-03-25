//
//  AuthenticationManager.swift
//  Alpface
//
//  Created by swae on 2018/3/25.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit


@objc(ALPAuthenticationManager)
final class AuthenticationManager: NSObject {
    static let shared = AuthenticationManager()
    private override init() {
       super.init()
    }
    
}
