//
//  UIView+FMViewFrame.m
//  小码哥彩票!
//
//  Created by 周发明 on 15/11/12.
//  Copyright © 2015年 周发明. All rights reserved.
//

#import "UIView+FMViewFrame.h"

@implementation UIView (FMViewFrame)

- (void)setCenterX:(CGFloat)centerX{
    CGPoint centerPoint = self.center;
    centerPoint.x = centerX;
    self.center = centerPoint;
}

- (CGFloat)centerX{
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY{
    CGPoint centerPoint = self.center;
    centerPoint.y = centerY;
    self.center = centerPoint;
    
}

- (CGFloat)centerY{
    return self.center.y;
}

- (void)setWidth:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)width{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height{
    return self.frame.size.height;
}

- (void)setX:(CGFloat)x{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x{
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y{
    return self.frame.origin.y;
}


- (BOOL)crossWithAnotherView:(UIView *)view{
    
    if (view == nil) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    
    CGRect rect1 = [self convertRect:self.bounds toView:nil];
    
    CGRect rect2 = [view convertRect:view.bounds toView:nil];
    
    return CGRectIntersectsRect(rect1, rect2);
    
}

@end
