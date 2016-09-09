//
//  IMGroupUserTool.h
//  qygt
//
//  Created by 周发明 on 16/8/17.
//  Copyright © 2016年 途购. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singler.h"
#import "IMUserItem.h"

@interface IMGroupUserTool : NSObject

SingleH(IMGroupUserTool)

@property(nonatomic, strong)NSArray *users;

@property(nonatomic, copy)void(^reloadNewUserNameBlock)();

+ (NSString *)nameWithSenderID:(NSString *)ID;

@end
