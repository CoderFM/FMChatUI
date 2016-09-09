//
//  IMBaseItemTool.m
//  qygt
//
//  Created by 周发明 on 16/8/15.
//  Copyright © 2016年 途购. All rights reserved.
//

#import "IMBaseItemTool.h"
#import "IMDownloadManager.h"
#import "IMBaseAttribute.h"
#import "IMSQLiteTool.h"
#import "NSData+AES.h"
#import "GTMBase64.h"
#import "IMUserItem.h"
#import "IMGroupUserTool.h"

@implementation IMBaseItemTool

+ (IMBaseItem *)itemMessageWithDic:(NSDictionary *)messageInfo{
    
    IMMessageBody *body = nil;
    /*
     imageMessage.image = messageInfo[@"image"];
     imageMessage.imageUrlString = messageInfo[@"O"];
     imageMessage.imageThumUrlString = messageInfo[@"T"]
     */
    
    /*
     voiceMessage.voiceUrlString = messageInfo[@"U"];
     voiceMessage.voiceData = messageInfo[@"VD"];
     voiceMessage.voiceSeconds = [messageInfo[@"L"] integerValue];
     */
    
    /*
     videoMessage.videoUrl = messageInfo[@"U"];
     videoMessage.coverImage = messageInfo[@"CI"];
     */
    
    switch ([messageInfo[@"MT"] integerValue]) {
        case IMMessageTextType:// 文本消息
            body = [[IMMessageBody alloc] initWithText:messageInfo[@"C"]];
            break;
        case IMMessagePictureType:// 照片
            body = [[IMMessageBody alloc] initWithImage:messageInfo[@"image"] imageUrlString:messageInfo[@"O"] imageThumUrlString:messageInfo[@"T"]];
            break;
        case IMMessageAudioType:
            body = [[IMMessageBody alloc] initWithVoiceData:messageInfo[@"VD"] voiceSeconds:[messageInfo[@"L"] integerValue] voiceUrlString:messageInfo[@"U"]];
            break;
        case IMMessageVideoType:
            body = [[IMMessageBody alloc] initWithCoverImage:messageInfo[@"CI"] videoUrl:messageInfo[@"U"]];
            break;
            
        default:
            break;
    }
    IMBaseItem *baseMessage = [IMBaseItem itemMessageBody:body];
    baseMessage.messageType = body.type;
    baseMessage.chatMessageIdentifier = [NSString stringWithFormat:@"%@", messageInfo[@"I"]];
    baseMessage.messageTime = [NSString stringWithFormat:@"%@", messageInfo[@"CT"]];
    
    baseMessage.senderID = [IMUserItem senderIDWithDecodeString:messageInfo[@"SI"]];
    baseMessage.senderNickName = [IMGroupUserTool nameWithSenderID:baseMessage.senderID];
    baseMessage.reviceID = [NSString stringWithFormat:@"%@", messageInfo[@"GI"]];
    
    [IMSQLiteTool savaWithMessage:baseMessage];
    
    return baseMessage;
}

+ (void)itemWithDict:(NSDictionary *)message success:(void (^)(IMBaseItem *))success{
    
    NSMutableDictionary *messageInfo = [NSMutableDictionary dictionaryWithDictionary:message];
    
    switch ([messageInfo[@"MT"] integerValue]) {
        case IMMessageTextType:
            if (success) success([self itemMessageWithDic:messageInfo]);
            break;
            
        case IMMessagePictureType:
        {
            NSString *fileName = [NSString stringWithFormat:@"thum%d%d.jpg", (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
            [IMDownloadManager downLoadImageUrl:messageInfo[@"T"] datePath:[IMBaseAttribute dataPicturePath] fileName:fileName completionHandler:^(NSString *thumFileName) {
                [messageInfo setObject:thumFileName forKey:@"T"];
                if (success) success([self itemMessageWithDic:messageInfo]);
            }];
        }
            break;
            
        case IMMessageAudioType:
            if (success) success([self itemMessageWithDic:messageInfo]);
            break;
            
        case IMMessageVideoType:
        {
            NSString *fileName = [NSString stringWithFormat:@"%d%d.jpg", (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
            [IMDownloadManager downLoadImageUrl:messageInfo[@"CI"] datePath:[IMBaseAttribute dataPicturePath] fileName:fileName completionHandler:^(NSString *thumFileName) {
                [messageInfo setObject:thumFileName forKey:@"CI"];
                IMBaseItem *item = [self itemMessageWithDic:messageInfo];
                if (success) success(item);
            }];
        }
            break;
            
        default:
            break;
    }
}

+ (IMBaseItem *)itemMessageWithBodyString:(NSString *)bodyString bodyType:(IMMessageType)type{
    IMMessageBody *body = nil;
    NSData *data = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    switch (type) {
        case IMMessageTextType:
            body = [[IMMessageBody alloc] initWithText:dict[@"messageText"]];
            break;
            
        case IMMessagePictureType:
            body = [[IMMessageBody alloc] initWithImage:nil imageUrlString:dict[@"imageUrlString"] imageThumUrlString:dict[@"imageThumUrlString"]];
            body.locationPath = dict[@"locationPath"];
            break;
            
        case IMMessageAudioType:
            body = [[IMMessageBody alloc] initWithVoiceData:nil voiceSeconds:[dict[@"voiceSeconds"] integerValue] voiceUrlString:dict[@"voiceUrlString"]];
            body.locationPath = dict[@"locationPath"];
            break;
            
        case IMMessageVideoType:
            body = [[IMMessageBody alloc] initWithCoverImage:dict[@"coverImage"] videoUrl:dict[@"videoUrl"]];
            body.locationPath = dict[@"locationPath"];
            break;
        default:
            break;
    }
    IMBaseItem *item = [IMBaseItem itemMessageBody:body];
    item.messageType = body.type;
    return item;
}

+ (NSString *)senderIDWithDecodeString:(NSString *)decodeString{
    
    NSString *STR = [NSString stringWithFormat:@"%@", decodeString];
    
    NSData *DATA = [GTMBase64 decodeString:STR];
    
    DATA = [DATA AES128DecryptWithKey:@"1234567890ABCDEF" iv:@"1234567890123456"];

    return [[NSString alloc] initWithData:DATA encoding:NSUTF8StringEncoding];
}

+ (void)messagesWithDicts:(NSArray *)dicts success:(void (^)(NSArray *))success{
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_queue_t queue = dispatch_queue_create("handlechatdata", NULL);
    
    __block NSMutableArray *arrM = [NSMutableArray array];
    
    [dicts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        dispatch_group_async(group, queue, ^{
            
            [self itemWithDict:obj success:^(IMBaseItem *item) {
                [arrM addObject:item];
            }];
            
        });
        
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (success) {
            success(arrM);
        }
    });
    
}

@end
