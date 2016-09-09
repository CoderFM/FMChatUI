//
//  LiveChatMoreView.h
//  qygt
//
//  Created by 周发明 on 16/6/21.
//  Copyright © 2016年 途购. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IMChatMoreView;

@protocol IMChatMoreViewDelegate <NSObject>

@required
- (void)IMChatMoreViewPhotoButtonClick:(IMChatMoreView *)livechatmoreview;

- (void)IMChatMoreViewCameraButtonClick:(IMChatMoreView *)livechatmoreview;

- (void)IMChatMoreViewVideoButtonClick:(IMChatMoreView *)livechatmoreview;

@end

@interface IMChatMoreView : UIView

@property(nonatomic, weak)id<IMChatMoreViewDelegate> delegate;

+ (instancetype)viewForXib;

+ (instancetype)viewForXibAndDelegate:(id<IMChatMoreViewDelegate>)delegate;

@end
