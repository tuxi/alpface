//
//  EditUserProfileModel.swift
//  Alpface
//
//  Created by swae on 2018/4/10.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

enum EditUserProfileModelType: Int {
    case textFieldOneLine
    case dateTime
    case textFieldMultiLine
}

class EditUserProfileModel: NSObject {
    public var title: String?
    public var content: String?
    public var placeholder: String?
    public var type: EditUserProfileModelType = .textFieldOneLine
    
    convenience init(title: String, content: String?, placeholder: String, type: EditUserProfileModelType = .textFieldOneLine) {
        self.init()
        self.title = title
        self.content = content
        self.placeholder = placeholder
        self.type = type
    }
}
