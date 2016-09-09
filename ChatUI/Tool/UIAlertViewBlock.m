//
//  UIAlertViewBlock.m
//  qygt
//
//  Created by 周发明 on 16/5/18.
//  Copyright © 2016年 赵越. All rights reserved.
//

#import "UIAlertViewBlock.h"
#import <UIKit/UIKit.h>

@interface UIAlertViewBlock ()<UIAlertViewDelegate>

@property(nonatomic, copy)void(^okBlock)();

@end

@implementation UIAlertViewBlock
SingleM(UIAlertViewBlock)

- (void)alertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelTitle okButtonTitle:(NSString *)okTitle withOkBlock:(void(^)())okBlock{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:okTitle, nil];
    
    self.okBlock = okBlock;
    
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {// 确定
        
        if (self.okBlock) {
            self.okBlock();
        }
        
    }
    
}

@end
