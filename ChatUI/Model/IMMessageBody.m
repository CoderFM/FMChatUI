//
//  IMMessageBody.m
//  qygt
//
//  Created by 周发明 on 16/8/5.
//  Copyright © 2016年 途购. All rights reserved.
//

#import "IMMessageBody.h"
#import "IMBaseAttribute.h"
#import "IMEmoticonConverter.h"

@implementation IMMessageBody

- (instancetype)initWithText:(NSString *)text{
    
    IMMessageBody *body = [[IMMessageBody alloc] init];
    
    body.messageText = text;
    
    body.type = IMMessageTextType;

    CGFloat maxWidth = [IMBaseAttribute shareIMBaseAttribute].bufferMaxWidth - [IMBaseAttribute shareIMBaseAttribute].contentTextInsetMargin * 2;
    
    CGRect rect = [[IMEmoticonConverter emoticonConverterWithInputString:text] boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    body.bodyHeight = rect.size.height;
    
    body.bodyWidth = (maxWidth > rect.size.width ? rect.size.width : maxWidth) + [IMBaseAttribute shareIMBaseAttribute].contentTextInsetMargin;
    
    return body;
}

- (instancetype)initWithImage:(UIImage *)image imageUrlString:(NSString *)imageUrlString imageThumUrlString:(NSString *)imageThumUrlString{
    
    IMMessageBody *body = [[IMMessageBody alloc] init];
    
    body.type = IMMessagePictureType;
    
    image = [UIImage imageWithContentsOfFile:[[IMBaseAttribute dataPicturePath] stringByAppendingPathComponent:imageThumUrlString]];
    
    body.imageUrlString = imageUrlString;
    
    body.imageThumUrlString = imageThumUrlString;
    
    body.image = image;
    
    body.bodyWidth = [IMBaseAttribute shareIMBaseAttribute].messageBodyImageWidth;
    
    if (image) {
        body.bodyHeight = image.size.height * [IMBaseAttribute shareIMBaseAttribute].messageBodyImageWidth / (image.size.width * 1.0);
    } else {
        body.bodyHeight = 50;
    }
    
    return body;
}

- (instancetype)initWithVoiceData:(NSData *)voiceData voiceSeconds:(NSUInteger)voiceSeconds voiceUrlString:(NSString *)voiceUrlString{
    IMMessageBody *body = [[IMMessageBody alloc] init];
    
    body.type = IMMessageAudioType;
    
    body.voiceData = voiceData;
    
    body.voiceSeconds = voiceSeconds;
    
    body.voiceUrlString = voiceUrlString;
    
    if (voiceSeconds > 60) {
        voiceSeconds = 60;
    }
    
    CGFloat width = [IMBaseAttribute shareIMBaseAttribute].messageBodyVoiceWidth * voiceSeconds / 60.0 + 40;
    
    body.bodyWidth = width;
    
    body.bodyHeight = [IMBaseAttribute shareIMBaseAttribute].messageBodyVoiceHeight;
    
    return body;

}

- (instancetype)initWithCoverImage:(NSString *)coverImage videoUrl:(NSString *)videoUrl{
    
    IMMessageBody *body = [[IMMessageBody alloc] init];
    
    body.type = IMMessageVideoType;
    
    body.videoUrl = videoUrl;
    
    body.coverImage = coverImage;
    
    body.bodyWidth = [IMBaseAttribute shareIMBaseAttribute].messageBodyVedioWidth;
    
    body.bodyHeight = [IMBaseAttribute shareIMBaseAttribute].messageBodyVedioHeight;
    
    return body;
}

@end
