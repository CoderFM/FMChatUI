//
//  IMBaseItemTool.h
//  qygt
//
//  Created by 周发明 on 16/8/15.
//  Copyright © 2016年 途购. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMBaseItem.h"

@interface IMBaseItemTool : NSObject

+ (void)itemWithDict:(NSDictionary *)dict success:(void(^)(IMBaseItem *item))success;

+ (IMBaseItem  *)itemMessageWithBodyString:(NSString *)bodyString bodyType:(IMMessageType)type;

+ (void)messagesWithDicts:(NSArray *)dicts success:(void(^)(NSArray *messages))success;

@end
