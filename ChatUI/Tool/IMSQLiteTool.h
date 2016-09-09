//
//  IMSQLiteTool.h
//  qygt
//
//  Created by 周发明 on 16/8/16.
//  Copyright © 2016年 途购. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

#define TABLE_NAME_PART(part) [NSString stringWithFormat:@"TugouSchoolChat%ld", part]

@class IMBaseItem;
@interface IMSQLiteTool : NSObject

+ (void)openSQLiteWithPartInteger:(NSInteger)part;

+ (void)savaWithMessage:(IMBaseItem *)message;

+ (void)updateMessage:(IMBaseItem *)message withKey:(NSString *)key;

+ (void)loadMessagesRerutnMessagesBlock:(void(^)(NSArray *messages))success;
/**
 *  用于查询本地数据库
 *
 *  @param messageID 相对于这条消息消息查询
 *  @param teacherID 针对这个ID查询
 *  @param isExclude 是否排除
 *  @param success   返回查询后的成功结果
 */
+ (void)loadMessagesWithMessageTime:(NSString *)messageTime reviceID:(NSString *)reviceID withTeacherID:(NSString *)teacherID isExclude:(BOOL)isExclude RerutnMessagesBlock:(void (^)(NSArray *))success;


+ (void)loadMessagesWithMessageTime:(NSString *)messageTime reviceID:(NSString *)reviceID withTeacherID:(NSString *)teacherID isExclude:(BOOL)isExclude RerutnBlock:(void (^)(BOOL))returnBlock;

+ (void)loadMessagesWithMessageID:(NSString *)messageID RerutnBlock:(void (^)(BOOL))returnBlock;

+ (void)deleteWithPart:(NSInteger)part;

@end

@interface FMDatabaseQueue (IMExtension)

+ (instancetype)shareQueue;

+ (instancetype)shareSaveQueue;

@end