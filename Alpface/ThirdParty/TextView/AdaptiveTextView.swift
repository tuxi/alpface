//
//  AdaptiveTextView.swift
//  Alpface
//
//  Created by xiaoyuan on 2018/4/17.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

typealias ALPTextHeightChangedBlock = (_ text: String, _ textHeight: CGFloat) -> Void

@objc(ALPAdaptiveTextView)
class AdaptiveTextView: UITextView {

    /// 占位文字
    public var placeholder: String? {
        didSet {
            self.placeholderView.text = placeholder
        }
    }
    
    /// 占位文字颜色
    public var placeholderColor: UIColor = UIColor.lightGray {
        didSet {
            self.placeholderView.textColor = placeholderColor
        }
    }
    
    /// 占位文本字体
    public var placeholderFont: UIFont? {
        didSet {
            self.placeholderView.font = placeholderFont
        }
    }
    
    /// textView最大行数
    public var maxNumberOfLines: Int = 1 {
        didSet {
            /**
             *  根据最大的行数计算textView的最大高度
             *  计算最大高度 = (每行高度 * 总行数 + 文字上下间距)
             */
            self.maxTextHeight = ceil((self.font?.lineHeight)! * CGFloat(maxNumberOfLines) + self.textContainerInset.top + self.textContainerInset.bottom)
        }
    }
    
    /// 文字高度改变的回调
    fileprivate var textChangedBlock: ALPTextHeightChangedBlock?
    
    /// 设置圆角
    public var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    /// UITextView作为placeholderView，使placeholderView等于UITextView的大小，字体重叠显示，方便快捷，解决占位符问题.
    fileprivate lazy var placeholderView: UITextView = {
        let placeholderView = UITextView.init(frame: self.bounds)
        // 防止textView输入时跳动问题
        placeholderView.isScrollEnabled = false
        placeholderView.showsVerticalScrollIndicator = false
        placeholderView.showsHorizontalScrollIndicator = false
        placeholderView.isUserInteractionEnabled = false
        placeholderView.font = self.placeholderFont
        placeholderView.textColor = placeholderColor
        placeholderView.backgroundColor = UIColor.clear
        return placeholderView
    }()
    
    
    /// 文字高度
    fileprivate var textHeight: CGFloat = 0
    
    /// 文字最大高度
    fileprivate var maxTextHeight: CGFloat = 0
    
    public func textValueDidChanged(callBack: ALPTextHeightChangedBlock?) {
        self.textChangedBlock = callBack
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        self.isScrollEnabled = false
        self.scrollsToTop = false
        self.showsHorizontalScrollIndicator = false
        self.enablesReturnKeyAutomatically = true
        self.layer.borderWidth = 1;
        self.layer.borderColor = UIColor.lightGray.cgColor
        // 实时监听textView值得改变
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: NSNotification.Name.UITextViewTextDidChange, object: self)
        self.prepareViews()
    }
    
    fileprivate func prepareViews() {
        self.placeholderFont = self.font
        self.addSubview(self.placeholderView)
    }
    
    @objc fileprivate func textDidChange() {
        // 根据文字内容决定placeholderView是否隐藏
        self.placeholderView.isHidden = (self.text.isEmpty == false)
        var height = self.sizeThatFits(CGSize(width: self.bounds.size.width, height: CGFloat.greatestFiniteMagnitude)).height
        height = max(height, self.bounds.size.height)
        if self.textHeight != height {
            // 高度不一样，就改变了高度
            self.isScrollEnabled = height > maxTextHeight && maxTextHeight > 0
            self.textHeight = height
            //当不可以滚动（即 <= 最大高度）时，传值改变textView高度
            if let block = self.textChangedBlock, self.isScrollEnabled == false {
                block(self.text, height)
                self.superview?.layoutIfNeeded()
                self.placeholderView.frame = self.bounds
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidChange, object: self)
    }
}
