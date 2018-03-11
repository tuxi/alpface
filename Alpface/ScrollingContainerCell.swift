//
//  ScrollingContainerCell
//  Alpface
//
//  Created by swae on 2018/3/11.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc(ALPScrollingContainerCell)
class ScrollingContainerCell: UICollectionViewCell {
    
    public var model: MainAppScrollingContainerItem? {
        didSet(newValue) {
            viewController = model?.model as? UIViewController
        }
    }
    
    private var viewController: UIViewController? {
        didSet(newValue) {
            if viewController == newValue {
                return
            }
            guard let view = viewController?.view else {
                return
            }
            
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
            
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[view]|", options: [], metrics: nil, views: ["view": view]))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view": view]))
        }
    }
    private var containerScrollView: UIScrollView?
    
}
