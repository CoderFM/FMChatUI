//
//  IMBaseCellAttribute.m
//  qygt
//
//  Created by 周发明 on 16/8/5.
//  Copyright © 2016年 途购. All rights reserved.
//

#import "IMBaseAttribute.h"

@implementation IMBaseAttribute

SingleM(IMBaseAttribute)

+ (void)initialize{
    
    [IMBaseAttribute shareIMBaseAttribute].normalMargin = 10;
    
    [IMBaseAttribute shareIMBaseAttribute].headImageViewWidth = 38;
    
    [IMBaseAttribute shareIMBaseAttribute].nameLabelFont = [UIFont systemFontOfSize:15];
    
    [IMBaseAttribute shareIMBaseAttribute].nameLabelTextColor = [UIColor colorWithRed:180 / 255.0 green:180 / 255.0 blue:180 / 255.0 alpha:1];
    
    [IMBaseAttribute shareIMBaseAttribute].nameInfoLabelFont = [UIFont systemFontOfSize:15];
    
    [IMBaseAttribute shareIMBaseAttribute].nameInfoLabelTextColor = [UIColor colorWithRed:200 / 255.0 green:200 / 255.0 blue:200 / 255.0 alpha:1];
    
    [IMBaseAttribute shareIMBaseAttribute].contentTextFont = [UIFont systemFontOfSize:15];
    
    [IMBaseAttribute shareIMBaseAttribute].contentTextColor = [UIColor blackColor];
    
    [IMBaseAttribute shareIMBaseAttribute].headImageViewCornerRadius = [IMBaseAttribute shareIMBaseAttribute].headImageViewWidth * 0.5;
    
    [IMBaseAttribute shareIMBaseAttribute].contentTextInsetMargin = 10;
    
    [IMBaseAttribute shareIMBaseAttribute].bufferMaxWidth = [UIScreen mainScreen].bounds.size.width - [IMBaseAttribute shareIMBaseAttribute].headImageViewWidth * 2 - [IMBaseAttribute shareIMBaseAttribute].normalMargin * 2 - [IMBaseAttribute shareIMBaseAttribute].contentTextInsetMargin * 2;
    
    [IMBaseAttribute shareIMBaseAttribute].messageBodyImageWidth = [UIScreen mainScreen].bounds.size.width * 0.4;
    
    [IMBaseAttribute shareIMBaseAttribute].messageBodyVoiceWidth = [UIScreen mainScreen].bounds.size.width * 0.5;
    
    [IMBaseAttribute shareIMBaseAttribute].messageBodyVoiceHeight = 20;
    
    [IMBaseAttribute shareIMBaseAttribute].messageBodyVedioHeight = 140 * ([UIScreen mainScreen].bounds.size.width / 320.0);
    
    [IMBaseAttribute shareIMBaseAttribute].messageBodyVedioWidth = 185 * ([UIScreen mainScreen].bounds.size.width / 320.0);
    
    [IMBaseAttribute shareIMBaseAttribute].downloadProgressDict = [NSMutableDictionary dictionary];
    
    [IMBaseAttribute shareIMBaseAttribute].uploadProgressDict = [NSMutableDictionary dictionary];
    
    [IMBaseAttribute shareIMBaseAttribute].timeViewHeight = 40;
    
}

+ (NSString*)dataVedioPath
{
    NSString *dataPath = [NSString stringWithFormat:@"%@/Library/appdata/chatbuffer%ld/vedio", NSHomeDirectory(), [IMBaseAttribute shareIMBaseAttribute].part];
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:dataPath]){
        [fm createDirectoryAtPath:dataPath
      withIntermediateDirectories:YES
                       attributes:nil
                            error:nil];
    }
    return dataPath;
}

+ (NSString*)dataAudioPath
{
    NSString *dataPath = [NSString stringWithFormat:@"%@/Library/appdata/chatbuffer%ld/audio", NSHomeDirectory(), [IMBaseAttribute shareIMBaseAttribute].part];
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:dataPath]){
        [fm createDirectoryAtPath:dataPath
      withIntermediateDirectories:YES
                       attributes:nil
                            error:nil];
    }
    return dataPath;
    
}

+ (NSString*)dataPicturePath
{
    NSString *dataPath = [NSString stringWithFormat:@"%@/Library/appdata/chatbuffer%ld/picture", NSHomeDirectory(), [IMBaseAttribute shareIMBaseAttribute].part];
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:dataPath]){
        [fm createDirectoryAtPath:dataPath
      withIntermediateDirectories:YES
                       attributes:nil
                            error:nil];
    }
    return dataPath;
}

@end
