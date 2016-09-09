//
//  IMAudioTool.h
//  qygt
//
//  Created by 周发明 on 16/8/9.
//  Copyright © 2016年 途购. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singler.h"

#define IMAudioTimeDurtion 0.05
#define IMAudioMaxDurtion 60

typedef void(^FinishEncodeBlock)(NSString *audioPath, CGFloat seconds);

typedef void(^FinishPlayBlock)(BOOL isFinish);

typedef void(^ReplacePlayFileName)(NSString *beforeFileName);

@class IMVoiceVolumeView;
@interface IMAudioTool : NSObject

+ (instancetype)shareAudioTool;

- (void)playWithFileName:(NSString *)fileName returnBeforeFileName:(ReplacePlayFileName)replaceBlock withFinishBlock:(FinishPlayBlock)playFinish;

- (void)stopPlay;

- (void)recorderVoiceVolumeView:(IMVoiceVolumeView *)volumeView finishBlock:(FinishEncodeBlock)finishBlock;

- (void)recorderPause;

- (void)recorderStop;

- (void)startEncode;

@end
