//
//  IMBaseItem.h
//  qygt
//
//  Created by 周发明 on 16/8/4.
//  Copyright © 2016年 途购. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMMessageBody.h"

typedef NS_ENUM(NSUInteger, IMMessageSendState){
    IMMessageSendSuccess = 0 /**< 消息发送成功 */,
    IMMessageSendFail /**< 消息发送失败 */,
    IMMessageSending/**< 消息发送中 */,
};

typedef NS_ENUM(NSUInteger, IMMessageReadState) {
    IMMessageUnRead = 0 /**< 消息未读 */,
    IMMessageReaded /**< 消息已读 */,
};



@interface IMBaseItem : NSObject
/**
 *  消息类型
 */
@property(nonatomic, assign)IMMessageType messageType;

/**
 *  发送状态
 */
@property(nonatomic, assign)IMMessageSendState sendState;
/**
 *  阅读状态
 */
@property(nonatomic, assign)IMMessageReadState readState;

/**
 *  消息体
 */
@property(nonatomic, strong)IMMessageBody *messageBody;
/**
 *  昵称附加信息
 */
@property(nonatomic, copy)NSString *nameDetail;
/**
 *  消息接收的时间戳
 */
@property (nonatomic, copy) NSString *messageTime;
/**
 *  消息接收时间字符串
 */
@property (nonatomic, copy) NSString *messageCT;
/**
 *  发送者昵称
 */
@property (nonatomic, copy) NSString *senderNickName ;
/**
 *  发送者头像链接
 */
@property (nonatomic, copy) NSString *senderAvatarThumb;
/**
 *  发送者ID
 */
@property (nonatomic, copy) NSString *senderID;
/**
 *  接收者ID
 */
@property (nonatomic, copy) NSString *reviceID;
/**
 *  消息的唯一标示符
 */
@property (nonatomic, copy) NSString *chatMessageIdentifier;
/**
 *  消息的ID
 */
@property (nonatomic, copy) NSString *chatMessageId;
/**
 *  创建消息时间
 */
@property(nonatomic, copy)NSString *creatTime;
/**
 *  cell的高度
 */
@property(nonatomic, assign)CGFloat cellHeight;
/**
 *  是否正在下载附件
 */
@property(nonatomic, assign)BOOL isDownloading;
/**
 *  消息发送时上传附近的进度
 */
@property(nonatomic, assign)CGFloat uploadProgress;
/**
 *  消息接收时下载附件的进度
 */
@property(nonatomic, assign)CGFloat downloadProgress;
/**
 *  是否显示时间
 */
@property(nonatomic, assign)BOOL isShowTime;
/**
 *  语音是否正在播放
 */
@property(nonatomic, assign)BOOL isPlaying;
/**
 *  消息显示的时候滚动到哪一行
 */
@property(nonatomic, assign)NSInteger scrollToIndex;
/**
 *  用消息构造消息实例
 *
 *  @param messageBody 消息体
 *
 *  @return 消息实例
 */
+ (instancetype)itemMessageBody:(IMMessageBody *)messageBody;
/**
 *  用图片的路径构造消息实例
 *
 *  @param imagePath 图片路径
 *
 *  @return 消息实例
 */
+ (instancetype)itemMessageImage:(NSString *)imagePath;
/**
 *  用视频构造消息实例
 *
 *  @param image    视频封面
 *  @param vedioUrl 视频的路径
 *
 *  @return 消息实例
 */
+ (instancetype)itemMessageCoverImage:(NSString *)image vedioFileName:(NSString *)vedioFileName;
/**
 *  用语音路径构造消息实例
 *
 *  @param voicePath 语音路径
 *  @param seconds   语音长度
 *
 *  @return 消息实例
 */
+ (instancetype)itemMessageVoicePath:(NSString *)voicePath seconds:(NSTimeInterval)seconds;

- (void)setUpWithOtherInfo;
/**
 *  用于包装发送消息
 *
 *  @return 发送时候的字典
 */
- (NSDictionary *)willSendMessage;
/**
 *  用于存到数据库中
 *
 *  @return 字典
 */

- (NSString *)bodyString;

@end
