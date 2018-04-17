//
//  MBProgressHUD+XYExtension.swift
//  Alpface
//
//  Created by swae on 2018/4/14.
//  Copyright © 2018年 alpface. All rights reserved.
//

import MBProgressHUD

typealias XYHUDActionCallBack = ((_ hud: MBProgressHUD) -> Void)

extension UIView {
    fileprivate struct MBProgressHUDKeys {
        static var xy_hudCancelOption = "com.alpface.MBProgressHUD.xy_hudCancelOption"
    }
    fileprivate var xy_hudCancelOption: XYHUDActionCallBack? {
        set {
            objc_setAssociatedObject(self, &MBProgressHUDKeys.xy_hudCancelOption, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &MBProgressHUDKeys.xy_hudCancelOption) as? XYHUDActionCallBack
        }
    }
    
    fileprivate func setBb_hudCancelOption(cancelOption: XYHUDActionCallBack?) {
        
    }
    @objc fileprivate func xy_cancelOperationAction(sender: UIButton) {
        
    }
}

extension MBProgressHUD {
    static let XYToastDefaultDuration: TimeInterval = 2.0
    fileprivate struct MBProgressHUDKeys {
        static var buttonPadding = "com.alpface.MBProgressHUD.buttonPadding"
    }
    
    var buttonPadding: Double {
        get {
            let padding = objc_getAssociatedObject(self, &MBProgressHUDKeys.buttonPadding) as? NSNumber
            guard let p = padding else {
                return 4.0
            }
            return p.doubleValue
        }
        set {
            if newValue.isEqual(to: buttonPadding) == false {
                let num = NSNumber(value: newValue)
                objc_setAssociatedObject(self, &MBProgressHUDKeys.buttonPadding, num, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                self.setNeedsUpdateConstraints()
            }
        }
    }
    
    // MARK: - Text
    class func xy_show(_ message: String) {
        self.xy_show(message, delay: XYToastDefaultDuration)
    }
    class func xy_show(_ message: String, delay: TimeInterval) {
        self.xy_show(message, delay: delay, offset: .zero)
    }
    
    class func xy_show(_ message: String, delay: TimeInterval, offset: CGPoint) {
        self.xy_show(message, delay: delay, toView: nil, offset: offset)
    }
    
    class func xy_show(_ message: String, delay: TimeInterval, toView: UIView?, offset: CGPoint) {
        var d = delay
        if d <= 0.0 {
            d = 2.0
        }
        let hud = self.xy_createHud(message: message, toView: toView, offset: offset)
        hud.mode = .text
        if d.isEqual(to: Double(Int64.max))  {
            hud.hide(animated: true, afterDelay: delay)
        }
    }
    
    // MARK: - Activity
    class func xy_showActivity() {
        self.xy_show(activity: 0)
    }
    
    class func xy_show(activity delay: TimeInterval) {
        self.xy_show(activity: delay, toView: nil)
    }
    
    class func xy_show(activity delay: TimeInterval, toView: UIView?) {
        self.xy_show(activity: nil, delay: delay, toView: nil, offset: .zero)
    }
    
    class func xy_show(activity message: String?, delay: TimeInterval, toView: UIView?, offset: CGPoint) {
        let hud = self.xy_createHud(message: message, toView: toView, offset: offset)
        hud.mode = .indeterminate
        hud.isSquare = true
        if delay > 0 {
            hud.hide(animated: true, afterDelay: delay)
        }
    }
    
    class func xy_show(activity message: String?, actionCallBack: XYHUDActionCallBack?) {
        _ = self.xy_showHud(to: nil, message: message, mode: .indeterminate, actionCallBack: actionCallBack)
    }
    
    class func xy_show(progress message: String?, actionCallBack: XYHUDActionCallBack?) -> MBProgressHUD {
        return self.xy_showHud(to: nil, message: message, mode: .determinate, actionCallBack: actionCallBack)
    }
    
    fileprivate class func xy_showHud(to view: UIView?, message: String?, mode: MBProgressHUDMode, actionCallBack: XYHUDActionCallBack?) -> MBProgressHUD {
        let hud = self.xy_createHud(message: message, toView: view, offset: .zero)
        hud.mode = mode
        let v = XY_HUD_NULL_VIEW(view: view)
        v.xy_hudCancelOption = actionCallBack
        hud.button.setTitle("取消", for: .normal)
        hud.button.setTitleColor(UIColor.white, for: .normal)
        hud.button.addTarget(view, action: #selector(xy_cancelOperationAction(sender:)), for: .touchUpInside)
        return hud
    }
    
    class func xy_show(custom image: UIImage, message: String, toView: UIView?, offset: CGPoint) {
        let hud = self.xy_createHud(message: message, toView: toView, offset: offset)
        hud.mode = .customView
        hud.customView = UIImageView.init(image: image)
        hud.hide(animated: true, afterDelay: XYToastDefaultDuration)
    }
    
    // MARK: - Init
    fileprivate class func xy_createHud(message: String?, toView: UIView?, offset: CGPoint) -> MBProgressHUD {
        let view = self.XY_HUD_NULL_VIEW(view: toView)
        let hud = MBProgressHUD.init(view: view)
        // 修改样式，否则等待框背景色将为半透明
        hud.bezelView.style = .solidColor
        // 设置等待框背景色为黑色
        hud.bezelView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        hud.removeFromSuperViewOnHide = true
        // 设置菊花框为白色
        UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [MBProgressHUD.self]).color = UIColor.white
        view.addSubview(hud)
        hud.label.font = UIFont.systemFont(ofSize: 15.0)
        hud.label.numberOfLines = 0
        // 设置间距为20.f
        hud.margin = 20.0
        hud.buttonPadding = 20.0
        // 正方形，就是宽高是否相同
        hud.isSquare = false
        // 设置内部控件的颜色，包括button的文本颜色，边框颜色，label的文本颜色等
        hud.contentColor = UIColor.white
        hud.offset = offset
        hud.show(animated: true)
        hud.label.text = message
        return hud
    }
    
    // MARK: - Hidden
    class func xy_hide() {
        guard let window = UIApplication.shared.delegate?.window else { return }
        self.hide(for: window!, animated: true)
        
    }
    
    fileprivate class func XY_HUD_NULL_VIEW(view: UIView?) -> UIView {
        if let v = view {
            return v
        }
        return ((UIApplication.shared.delegate?.window)!)!
        
    }
    
    fileprivate func updatePaddingConstraints() {
        // 下面修改自MBprogressHUD，实现更改间距
        // Set padding dynamically, depending on whether the view is visible or not
        guard let paddingConstraints = self.value(forKey: "paddingConstraints") as? [NSLayoutConstraint] else { return }
        
        var hasVisibleAncestors: Bool = false
        for padding in paddingConstraints {
            let firstView = padding.firstItem as? UIView
            let secondView = padding.secondItem as? UIView
            let firstViewContentSize = firstView?.intrinsicContentSize ?? CGSize.zero
            let secondViewContentSize = secondView?.intrinsicContentSize ?? CGSize.zero
            let firstVisible = firstView?.isHidden == false && firstViewContentSize.equalTo(.zero) == false
            let secondVisible = secondView?.isHidden == false && secondViewContentSize.equalTo(.zero) == false

            // Set if both views are visible or if there's a visible view on top that doesn't have padding
            // added relative to the current view yet
            padding.constant = (firstVisible && (secondVisible || hasVisibleAncestors)) ? 4.0 : 0.0
            if (padding.constant != 0) {
                if firstView?.isEqual(self.button) == true || secondView?.isEqual(self.button) == true {
                    padding.constant = CGFloat(self.buttonPadding)
                }
            }
            hasVisibleAncestors = (hasVisibleAncestors || secondVisible)
        }
        
    }
   
}

