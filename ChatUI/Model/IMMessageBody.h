//
//  IMMessageBody.h
//  qygt
//
//  Created by 周发明 on 16/8/5.
//  Copyright © 2016年 途购. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum{
    IMMessageTextType = 0, // 文本类型
    IMMessagePictureType = 1, // 图片类型
    IMMessageAudioType = 2, // 音频类型
    IMMessageVideoType = 3, // 视频类型
} IMMessageType;

@interface IMMessageBody : NSObject
/**
 *  内容类型
 */
@property(nonatomic, assign)IMMessageType type;
/**
 *  内容高度
 */
@property(nonatomic, assign)CGFloat bodyHeight;
/**
 *  内容宽度
 */
@property(nonatomic, assign)CGFloat bodyWidth;

@property (nonatomic, copy) NSString *locationPath;//本地路径（声音、图片、视频）

//文本消息 安全提醒
@property (nonatomic, copy) NSString *messageText /**< 消息文字 */;
//图片
@property(nonatomic, strong)UIImage *image;
@property (nonatomic, copy) NSString *imageUrlString /**< 需要显示的图片地址 */;
@property (nonatomic, copy) NSString *imageThumUrlString /**< 需要显示的图片地址 */;
@property (nonatomic, copy) NSString *prossNum;//图片读取率
//录音
@property (nonatomic, strong) NSData *voiceData /**< 录音data */;
@property (nonatomic, assign) NSUInteger voiceSeconds /**< 录音时间 */;
@property (nonatomic, copy) NSString *voiceUrlString /**< 录音地址 */;
//视频
@property (nonatomic, strong) NSString *coverImage;//视频封面
@property (nonatomic, copy) NSString *videoUrl;//视频下载地址
/**
 *  文本类型的消息内容实体
 *
 *  @param text 消息内容
 *
 *  @return 消息内容实体
 */
- (instancetype)initWithText:(NSString *)text;
/**
 *  图片类型的消息内容实体
 *
 *  @param image              照片
 *  @param imageUrlString     大图链接
 *  @param imageThumUrlString 小图链接
 *
 *  @return 图片内容实体
 */
- (instancetype)initWithImage:(UIImage *)image imageUrlString:(NSString *)imageUrlString imageThumUrlString:(NSString *)imageThumUrlString;
/**
 *  音频内容消息实体
 *
 *  @param voiceData      <#voiceData description#>
 *  @param voiceSeconds   <#voiceSeconds description#>
 *  @param voiceUrlString <#voiceUrlString description#>
 *
 *  @return <#return value description#>
 */
- (instancetype)initWithVoiceData:(NSData *)voiceData voiceSeconds:(NSUInteger)voiceSeconds voiceUrlString:(NSString *)voiceUrlString;

- (instancetype)initWithCoverImage:(NSString *)coverImage videoUrl:(NSString *)videoUrl;

@end
