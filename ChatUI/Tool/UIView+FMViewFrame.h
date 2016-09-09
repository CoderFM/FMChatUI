//
//  UIView+FMViewFrame.h
//  小码哥彩票!
//
//  Created by 周发明 on 15/11/12.
//  Copyright © 2015年 周发明. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FMViewFrame)

@property(nonatomic, assign)CGFloat width;

@property(nonatomic, assign)CGFloat height;

@property(nonatomic, assign)CGFloat x;

@property(nonatomic, assign)CGFloat y;

@property(nonatomic, assign)CGFloat centerX;

@property(nonatomic, assign)CGFloat centerY;

- (BOOL)crossWithAnotherView:(UIView *)view;

@end
