//
//  UIButton+VerificationCode.swift
//  Alpface
//
//  Created by swae on 2019/6/30.
//  Copyright © 2019 alpface. All rights reserved.
//

import Foundation

var VerificationCode: Int = 60

class VerificationCodeButton: UIButton {
    var codeTimer = DispatchSource.makeTimerSource(queue:DispatchQueue.global())
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setTitleColor(.white, for: .normal)
        self.setTitleColor(.gray, for: .highlighted)
        self.setTitleColor(.gray, for: .disabled)
        self.setTitle("获取验证码", for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if !codeTimer.isCancelled {
            codeTimer.cancel()
        }
    }
    
    // 倒计时启动
    func countDown(count: Int){
        
        // 倒计时开始,禁止点击事件
        isEnabled = false
    
        var remainingCount: Int = count {
            
            willSet {
                
                setTitle("\(newValue)秒重发", for: .normal)
  
                if newValue <= 0 {
                    
                    setTitle("获取验证码", for: .normal)
                    
                }
                
            }
            
        }
        
        if codeTimer.isCancelled {
            
            codeTimer = DispatchSource.makeTimerSource(queue:DispatchQueue.global())
            
        }
        
        // 设定这个时间源是每秒循环一次，立即开始
        codeTimer.schedule(deadline: .now(), repeating: .seconds(1))
        
        // 设定时间源的触发事件
        codeTimer.setEventHandler {[weak self] in
            
            // 返回主线程处理一些事件，更新UI等等
            
            DispatchQueue.main.async {
                
                // 每秒计时一次
                
                remainingCount -= 1
                
                // 时间到了取消时间源
                
                if remainingCount <= 0 {
                    
                    self?.isEnabled = true
                    self?.codeTimer.cancel()
                    
                }
                
            }
        }

        // 启动时间源
        codeTimer.resume()
        
    }
    
    //取消倒计时
    func countdownCancel() {
        
        if !codeTimer.isCancelled {
            
            codeTimer.cancel()
        }
        
        
        
        // 返回主线程
        DispatchQueue.main.async {
            self.isEnabled = true
            
            if self.titleLabel?.text?.count != 0 {
                self.setTitle("获取验证码", for: .normal)
            }
        }
        
    }
    
}


