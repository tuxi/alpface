//
//  CollectionViewSection.swift
//  Alpface
//
//  Created by swae on 2018/3/11.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc(ALPCollectionViewSection)
public class CollectionViewSection: NSObject {
    
    public var items: [BaseCellModel] = [BaseCellModel]()
    public var section: Int = 0
    public var indexPtahs: [IndexPath] {
        get {
            if items.count == 0 {
                return [IndexPath]()
            }
            var indexPaths: [IndexPath] = [IndexPath]()
            for item in 0...(items.count - 1) {
                let indexPath = IndexPath(item: item, section: section)
                indexPaths.append(indexPath)
            }
            return indexPaths
        }
    }
    
}
