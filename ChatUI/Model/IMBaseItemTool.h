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
/**
 *  字典转模型
 *
 *  @param dict    字典
 *  @param success 模型
 */
+ (void)itemWithDict:(NSDictionary *)dict success:(void(^)(IMBaseItem *item))success;
/**
 *  从本地加载数据转模型
 *
 *  @param bodyString 消息内容字符串
 *  @param type       消息类型
 *
 *  @return 消息实体
 */
+ (IMBaseItem  *)itemMessageWithBodyString:(NSString *)bodyString bodyType:(IMMessageType)type;
/**
 *  拉取的数据处理
 *
 *  @param dicts   全部消息的字典
 *  @param success 返回转成功的模型数组
 */
+ (void)messagesWithDicts:(NSArray *)dicts success:(void(^)(NSArray *messages))success;

@end
