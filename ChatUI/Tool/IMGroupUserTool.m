//
//  IMGroupUserTool.m
//  qygt
//
//  Created by 周发明 on 16/8/17.
//  Copyright © 2016年 途购. All rights reserved.
//

#import "IMGroupUserTool.h"


@implementation IMGroupUserTool
SingleM(IMGroupUserTool)

+ (NSString *)nameWithSenderID:(NSString *)ID{
    if ([IMGroupUserTool shareIMGroupUserTool].users){
        NSArray *IDS = [[IMGroupUserTool shareIMGroupUserTool].users valueForKeyPath:@"FI"];
        if ([IDS containsObject:ID]) {
            NSInteger index = [IDS indexOfObject:ID];
            IMUserItem *item = [IMGroupUserTool shareIMGroupUserTool].users[index];
            return item.NN;
        } else {
            return @"导游";
        }
    } else {
        return @"导游";
    }
}

- (void)setUsers:(NSArray *)users{
    _users = users;
    if (self.reloadNewUserNameBlock) {
        self.reloadNewUserNameBlock();
    }
    
}

@end
