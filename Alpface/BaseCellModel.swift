//
//  BaseCellModel.swift
//  Alpface
//
//  Created by swae on 2018/3/11.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

protocol CellModelProtocol: NSObjectProtocol {
    var model: AnyObject? { set get }
    var height: CGFloat? { set get }
    var indexPath: IndexPath? { set get }
}

@objc(ALPBaseCellModel)
public class BaseCellModel: NSObject, CellModelProtocol {
    var model: AnyObject?
    
    var height: CGFloat?
    
    var indexPath: IndexPath?
    

}
