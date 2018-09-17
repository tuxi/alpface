//
//  OSProgressView.m
//  ProgressBarDemo
//
//  Created by alpface on 15/08/2017.
//  Copyright © 2017 alpface. All rights reserved.
//

#import "OSProgressView.h"

@implementation OSProgressView
{
    NSLayoutConstraint *_progressBarWidthConstraint;
}

@synthesize trackTintColor = _trackTintColor, progressTintColor = _progressTintColor;

////////////////////////////////////////////////////////////////////////
#pragma mark - initializer
////////////////////////////////////////////////////////////////////////

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self  = [super initWithFrame:frame]) {
        _progressBarWidthConstraint = [NSLayoutConstraint constraintWithItem:self.progressBar
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0
                                                                    constant:0.0];
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.progressBar
                                                                          attribute:NSLayoutAttributeLeft
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self
                                                                          attribute:NSLayoutAttributeLeft
                                                                         multiplier:1.0
                                                                           constant:0.0];
        
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.progressBar
                                                                            attribute:NSLayoutAttributeBottom
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1.0
                                                                             constant:0.0];
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.progressBar
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0
                                                                          constant:0.0];
        [self addSubview:self.progressBar];
        self.backgroundColor = self.trackTintColor;
        self.progressBar.backgroundColor = self.progressTintColor;
        self.progressBar.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:@[_progressBarWidthConstraint, topConstraint, bottomConstraint, leftConstraint]];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods
////////////////////////////////////////////////////////////////////////

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    self.progressBar.alpha = 1.0;
    self.progress = progress;
    NSTimeInterval duration = animated ? 0.1 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)setTrackTintColor:(UIColor *)trackTintColor {
    _trackTintColor = trackTintColor;
    self.backgroundColor = trackTintColor;
}

- (UIColor *)trackTintColor {
    return _trackTintColor ?: [UIColor clearColor];
}

- (void)setProgressTintColor:(UIColor *)progressTintColor {
    _progressTintColor = progressTintColor;
    self.progressBar.backgroundColor = progressTintColor;
}

- (UIColor *)progressTintColor {
    return _progressTintColor ?: [UIColor greenColor];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    CGFloat tempProgress = self.progress;
    self.progress = tempProgress;
}

- (void)finishProgress {
    
    [self setProgress:1.0 animated:YES];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.progressBar.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.progress = 0.0;
    }];
}

- (void)cancelProgress {
    
    [self setProgress:0.0 animated:YES];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.progressBar.alpha = 0.0;
    }];
}

- (void)setProgressHeight:(CGFloat)progressHeight {
    CGRect rect = self.frame;
    rect.origin.y = self.superview.frame.size.height - progressHeight;
    rect.size.height = progressHeight;
    self.frame = rect;
}

- (CGFloat)progressHeight {
    return self.frame.size.height;
}


////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods
////////////////////////////////////////////////////////////////////////

- (void)setProgress:(CGFloat)progress {
    _progress = MIN(1, progress);
    _progressBarWidthConstraint.constant = self.bounds.size.width * progress;
}


- (UIImageView *)progressBar {
    if (!_progressBar) {
        _progressBar = [UIImageView new];
    }
    return _progressBar;
}



@end
