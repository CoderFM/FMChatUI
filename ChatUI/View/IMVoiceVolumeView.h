//
//  IMVoiceVolumeView.h
//  qygt
//
//  Created by 周发明 on 16/8/11.
//  Copyright © 2016年 途购. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    IMVoiceVolumeViewNormalType,
    IMVoiceVolumeViewCancelType,
    IMVoiceVolumeViewCountDownType,
    IMVoiceVolumeViewRemindType
} IMVoiceVolumeViewType;

@interface IMVoiceVolumeView : UIView
/**
 *  根据声音大小显示不同view
 *
 *  @param volumn 声音的分贝大小
 */
- (void)volunmeWithSound:(CGFloat)volumn;
/**
 *  取消录音的样式
 */
- (void)volunmeViewCancel;
/**
 *  正常的样式
 */
- (void)volunmeViewNormal;
/**
 *  倒计时时间样式
 */
- (void)volunmeViewCountDown;
/**
 *  开始到实际的方法
 */
- (void)volunmeViewCountDownBegin;
/**
 *  显示录音太短
 */
- (void)showShortTimeModel;
/**
 *  说话过长
 */
- (void)showLongTimeModel;

@end
