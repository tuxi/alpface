//
//  NSAttributedString+Extension.swift
//  Alpface
//
//  Created by xiaoyuan on 2018/4/18.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

extension NSAttributedString {
    
    /// 获取当前富文本字符串的size
    func getSize(maxWidth: CGFloat) -> CGSize {
        
        let size = self.boundingRect(with: CGSize(width: maxWidth, height: 1000), options:(NSStringDrawingOptions.usesLineFragmentOrigin), context:nil).size
        
        return size
    }
    
    
    /// 将富文本字符串转换为图片
    func createUIImage(maxWidth:CGFloat) -> UIImage {
        let size = self.getSize(maxWidth: maxWidth)
        
        UIGraphicsBeginImageContextWithOptions(size, false , 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension NSString {
    /// 转换字符串为图片
    func imageFromText(_ text:NSString, font:UIFont, maxWidth:CGFloat, color:UIColor) -> UIImage {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraph.alignment = .center // potentially this can be an input param too, but i guess in most use cases we want center align
        
        let attributedString = NSAttributedString(string: text as String, attributes: [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.paragraphStyle:paragraph])
        
        let size = attributedString.getSize(maxWidth: maxWidth)
        UIGraphicsBeginImageContextWithOptions(size, false , 0.0)
        attributedString.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
