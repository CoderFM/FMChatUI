//
//  IMBaseItem.m
//  qygt
//
//  Created by 周发明 on 16/8/4.
//  Copyright © 2016年 途购. All rights reserved.
//

#import "IMBaseItem.h"
#import "IMBaseAttribute.h"
#import "IMImagePickerManager.h"
#import "MJExtension.h"

@implementation IMBaseItem

+ (instancetype)itemMessageBody:(IMMessageBody *)messageBody{
    
    IMBaseItem *item = [[IMBaseItem alloc] init];
    
    item.messageBody = messageBody;
    
    item.cellHeight = 20 + 15 + 10 + messageBody.bodyHeight + 30 + 10;
    
    return item;
}

+ (instancetype)itemMessageText:(NSString *)text{
    
    IMMessageBody *body = [[IMMessageBody alloc] initWithText:text];
    
    return [self itemMessageBody:body];
}

+ (instancetype)itemMessageImage:(NSString *)imagePath{
    
    IMMessageBody *body = [[IMMessageBody alloc] initWithImage:nil imageUrlString:@"" imageThumUrlString:imagePath];
    
    body.locationPath = imagePath;
    
    return [self itemMessageBody:body];
    
}

+ (instancetype)itemMessageCoverImage:(NSString *)coverImage vedioFileName:(NSString *)vedioFileName{
    IMMessageBody *body = [[IMMessageBody alloc] initWithCoverImage:coverImage videoUrl:@""];
    body.image = [UIImage imageWithContentsOfFile:[[IMBaseAttribute dataPicturePath] stringByAppendingPathComponent:coverImage]];
    body.locationPath = vedioFileName;
    return [self itemMessageBody:body];
}

+ (instancetype)itemMessageVoicePath:(NSString *)voicePath seconds:(NSTimeInterval)seconds{
    NSData *data = [NSData dataWithContentsOfFile:[[IMBaseAttribute dataAudioPath] stringByAppendingPathComponent:voicePath]];
    IMMessageBody *body = [[IMMessageBody alloc] initWithVoiceData:data voiceSeconds:seconds voiceUrlString:@""];
    body.locationPath = voicePath;
    return [self itemMessageBody:body];
}

- (void)setIsShowTime:(BOOL)isShowTime{
    _isShowTime = isShowTime;
    CGFloat timeViewHeight = isShowTime ? [IMBaseAttribute shareIMBaseAttribute].timeViewHeight : 0;
    self.cellHeight = 20 + 15 + 10 + self.messageBody.bodyHeight + 30 + 10 + timeViewHeight;
}

- (void)setUpWithOtherInfo{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 2016-08-15 22:24:06
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    self.senderNickName = @"测试";
    self.senderAvatarThumb = @"http://img0.pconline.com.cn/pconline/1312/27/4072897_01.gif";
    self.messageTime = [formatter stringFromDate:[NSDate date]];
    self.senderID = @"11";
    self.reviceID = [IMBaseAttribute shareIMBaseAttribute].reciverID;
    self.messageType = self.messageBody.type;
    self.chatMessageIdentifier = [NSString stringWithFormat:@"%d%d", (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000000];
}

- (NSDictionary *)willSendMessage{
    
    NSDictionary *sendMessage = nil;
    
    switch (self.messageType) {
        case IMMessageTextType:
            sendMessage = @{@"C":self.messageBody.messageText,@"MT":@"0",@"GI":self.reviceID};
            break;
        case IMMessagePictureType:
            sendMessage = @{@"O":self.messageBody.imageUrlString,@"MT":@"1",@"T":self.messageBody.imageThumUrlString,@"GI":self.reviceID};
            break;
        case IMMessageAudioType:
            sendMessage = @{@"U":self.messageBody.voiceUrlString,@"MT":@"2",@"GI":self.reviceID,@"L":[NSString stringWithFormat:@"%ld",(unsigned long)self.messageBody.voiceSeconds]};
            break;
        case IMMessageVideoType:
            sendMessage = @{@"U":self.messageBody.videoUrl,@"MT":@"3",@"CI":self.messageBody.coverImage,@"GI":self.reviceID};
            break;
        default:
            break;
    }
    
    return sendMessage;
}

- (NSString *)bodyString{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    switch (self.messageType) {
        case IMMessageTextType:
            [dict setObject:self.messageBody.messageText forKey:@"messageText"];
            break;
            
        case IMMessagePictureType:
            [dict setObject:self.messageBody.locationPath ? : @"" forKey:@"locationPath"];
            [dict setObject:self.messageBody.imageThumUrlString ? : @"" forKey:@"imageThumUrlString"];
            [dict setObject:self.messageBody.imageUrlString ? : @"" forKey:@"imageUrlString"];
            break;
            
        case IMMessageAudioType:
            [dict setObject:self.messageBody.locationPath ? : @"" forKey:@"locationPath"];
            [dict setObject:self.messageBody.voiceUrlString ? : @"" forKey:@"voiceUrlString"];
            [dict setObject:@(self.messageBody.voiceSeconds) ? : @"" forKey:@"voiceSeconds"];
            break;
            
        case IMMessageVideoType:
            [dict setObject:self.messageBody.locationPath ? : @"" forKey:@"locationPath"];
            [dict setObject:self.messageBody.videoUrl ? : @"" forKey:@"videoUrl"];
            [dict setObject:self.messageBody.coverImage ? : @"" forKey:@"coverImage"];
            break;
        default:
            break;
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return string;
    
}

- (NSString *)description{
    return [NSString stringWithFormat:@"bodyString: %@", self.bodyString];
}

@end
