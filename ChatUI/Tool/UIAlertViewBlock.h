//
//  UIAlertViewBlock.h
//  qygt
//
//  Created by 周发明 on 16/5/18.
//  Copyright © 2016年 赵越. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singler.h"

@interface UIAlertViewBlock : NSObject
SingleH(UIAlertViewBlock)

- (void)alertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelTitle okButtonTitle:(NSString *)okTitle withOkBlock:(void(^)())okBlock;

@end
