//
//  IMSQLiteTool.m
//  qygt
//
//  Created by 周发明 on 16/8/16.
//  Copyright © 2016年 途购. All rights reserved.
//

#import "IMSQLiteTool.h"
#import "IMBaseItem.h"
#import "IMBaseItemTool.h"

static NSString *tableName = @"";

@implementation IMSQLiteTool

+ (void)openSQLiteWithPartInteger:(NSInteger)part{
    
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY NOT NULL ,messageType INTEGER ,sendState INTEGER ,messageTime TEXT, senderNickName TEXT, senderAvatarThumb TEXT, senderID TEXT, reviceID TEXT, chatMessageIdentifier TEXT, messageBody TEXT);", TABLE_NAME_PART(part)];
    
    [[FMDatabaseQueue shareQueue] inDatabase:^(FMDatabase *db) {
        if ([db open]){
            [db executeUpdate:sql];
            tableName = TABLE_NAME_PART(part);
        };
    }];
    
}

+ (void)savaWithMessage:(IMBaseItem *)message{
    
    if ([message isKindOfClass:[IMBaseItem class]]){
        
        [self deleteItemWithMessages:message];
        
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (messageType,sendState,messageTime,senderNickName,senderAvatarThumb, senderID,reviceID,chatMessageIdentifier,messageBody) VALUES(%zd,%zd,'%@','%@','%@','%@','%@','%@','%@') ", tableName,message.messageType,message.sendState,message.messageTime ? : @"",message.senderNickName ? : @"",message.senderAvatarThumb ? : @"",message.senderID ? : @"",message.reviceID ? : @"",message.chatMessageIdentifier ? : @"",message.bodyString ? : @""];
        
        [[FMDatabaseQueue shareSaveQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
            if ([db open]) {
                [db executeUpdate:sql];
            }
        }];
    }
}

+ (void)updateMessage:(IMBaseItem *)message withKey:(NSString *)key{
    
    NSString *sql = @"";
    
    if ([key isEqualToString:@"messageBody"]) {
        sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE chatMessageIdentifier = '%@';", tableName, key, message.bodyString, message.chatMessageIdentifier];
    } else {
        sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE chatMessageIdentifier = '%@';", tableName, key, [message valueForKeyPath:key], message.chatMessageIdentifier];
    }
    
    [[FMDatabaseQueue shareQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([db open]) {
            [db executeUpdate:sql];
        }
    }];
    
}

+ (void)loadMessagesRerutnMessagesBlock:(void (^)(NSArray *))success{
    
    NSMutableArray *arrM = [NSMutableArray array];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ LIMIT 0,20;", tableName];
    
    [[FMDatabaseQueue shareQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *set =  [db executeQuery:sql];
        while ([set next]) { //等价于 == sqlite_Row
            [arrM addObject:[self itemWithFMResultSet:set]];
        }
        if (success) {
            success(arrM);
        }
    }];
}

+ (void)loadMessagesWithMessageTime:(NSString *)messageTime reviceID:(NSString *)reviceID withTeacherID:(NSString *)teacherID isExclude:(BOOL)isExclude RerutnMessagesBlock:(void (^)(NSArray *))success{
    
    NSString *sql = @"";
    
    if (messageTime.length > 0) {
        if (isExclude) {
            
            sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE messageTime < datetime('%@')  AND senderID != '%@' AND reviceID = '%@' ORDER BY messageTime DESC LIMIT 0,10;", tableName, messageTime, teacherID, reviceID];
            
        } else {
            sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE messageTime < datetime('%@') AND senderID = '%@' AND reviceID = '%@' ORDER BY messageTime DESC LIMIT 0,10;", tableName, messageTime, teacherID, reviceID];
        }
        
    } else {
        
        if (isExclude) {
            
            sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE senderID != '%@' AND reviceID = '%@' ORDER BY messageTime LIMIT 0,10;", tableName, teacherID, reviceID];
            
        } else {
            sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE senderID = '%@' AND reviceID = '%@' ORDER BY messageTime LIMIT 0,10;", tableName, teacherID, reviceID];
        }
        
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    
    [[FMDatabaseQueue shareQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *set =  [db executeQuery:sql];
        while ([set next]) {
            [arrM addObject:[self itemWithFMResultSet:set]];
        }
        if (success) {
            success(arrM);
        }
    }];
    
}

+ (void)loadMessagesWithMessageTime:(NSString *)messageTime reviceID:(NSString *)reviceID withTeacherID:(NSString *)teacherID isExclude:(BOOL)isExclude RerutnBlock:(void (^)(BOOL))returnBlock{
    
    
    NSString *sql = @"";
    
    if (messageTime.length > 0) {
        if (isExclude) {
            
            sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE messageTime < datetime('%@')  AND senderID != '%@' AND reviceID = '%@' ORDER BY messageTime DESC LIMIT 0,1;", tableName, messageTime, teacherID, reviceID];
            
        } else {
            sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE messageTime < datetime('%@') AND senderID = '%@' AND reviceID = '%@' ORDER BY messageTime DESC LIMIT 0,1;", tableName, messageTime, teacherID, reviceID];
        }
        
    } else {
        
        if (isExclude) {
            
            sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE senderID != '%@' AND reviceID = '%@' ORDER BY messageTime LIMIT 0,1;", tableName, teacherID, reviceID];
            
        } else {
            sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE senderID = '%@' AND reviceID = '%@' ORDER BY messageTime LIMIT 0,1;", tableName, teacherID, reviceID];
        }
        
    }
    
    [[FMDatabaseQueue shareQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *set =  [db executeQuery:sql];
        while ([set next]) {
            if (returnBlock) {
                returnBlock(YES);
            }
        }
    }];
    
}

+ (void)loadMessagesWithMessageID:(NSString *)messageID RerutnBlock:(void (^)(BOOL))returnBlock{
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE chatMessageIdentifier = '%@';",tableName, messageID];
    
    [[FMDatabaseQueue shareQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *set =  [db executeQuery:sql];
        while ([set next]) {
            if (returnBlock) {
                returnBlock(YES);
            }
        }
    }];
    
}

+ (void)deleteItemWithMessages:(IMBaseItem *)message{
    
    if ([message isKindOfClass:[IMBaseItem class]] && message.chatMessageIdentifier > 0){
        
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE chatMessageIdentifier = '%@';", tableName, message.chatMessageIdentifier];
        
        [[FMDatabaseQueue shareQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
            [db executeUpdate:sql];
        }];
    }
}

+ (IMBaseItem *)itemWithFMResultSet:(FMResultSet *)set{
    NSUInteger type = [set intForColumn:@"messageType"];
    NSString *bodyString = [set stringForColumn:@"messageBody"];
    IMBaseItem *item = [IMBaseItemTool itemMessageWithBodyString:bodyString bodyType:(int)type];
    [item setValue:[set stringForColumn:@"chatMessageIdentifier"] forKey:@"chatMessageIdentifier"];
    item.sendState = [set intForColumn:@"sendState"];
    item.messageTime = [NSString stringWithFormat:@"%@", [set stringForColumn:@"messageTime"]];
    item.senderNickName = [set stringForColumn:@"senderNickName"];
    item.senderAvatarThumb = [set stringForColumn:@"senderAvatarThumb"];
    item.senderID = [set stringForColumn:@"senderID"];
    item.reviceID = [set stringForColumn:@"reviceID"];
    return item;
}

+ (void)deleteWithPart:(NSInteger)part{
    
    NSString *sql = [NSString stringWithFormat:@"DROP TABLE %@;", TABLE_NAME_PART(part)];
    
    [[FMDatabaseQueue shareQueue] inDatabase:^(FMDatabase *db) {
        if ([db open]){
            [db executeUpdate:sql];
        };
    }];
    
    NSString *imageDir = [NSString stringWithFormat:@"%@/Library/appdata/chatbuffer%ld", NSHomeDirectory(), part];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    [fileManager removeItemAtPath:imageDir error:nil];
}

@end

#define DB_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)  lastObject]

static FMDatabaseQueue *manager = nil;

static FMDatabaseQueue *saveQueue = nil;

@implementation FMDatabaseQueue (IMExtension)

+ (instancetype)shareQueue{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FMDatabaseQueue alloc] initWithPath:[DB_PATH stringByAppendingPathComponent:@"tugouschool.db"]];
    });
    
    return manager;
}

+ (instancetype)shareSaveQueue{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        saveQueue = [[FMDatabaseQueue alloc] initWithPath:[DB_PATH stringByAppendingPathComponent:@"tugouschool.db"]];
    });
    
    return saveQueue;
}

@end