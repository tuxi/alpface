//
//  SettingsTableViewCellModel.swift
//  Alpface
//
//  Created by swae on 2018/4/15.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

class SettingsTableViewCellModel: NSObject {
    public var name: String?
    public var clickArrowCallBack: ((_ model: SettingsTableViewCellModel) -> Void)?
    
    convenience init(name: String?, clickArrowCallBack: ((_ model: SettingsTableViewCellModel) -> Void)?) {
        self.init()
        self.name = name
        self.clickArrowCallBack = clickArrowCallBack
    }
    
}
