//
//  SchoolChatToolBar.h
//  qygt
//
//  Created by 周发明 on 16/8/4.
//  Copyright © 2016年 途购. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMChatMoreView.h"
#import "IMAudioTool.h"
#import "IMBaseItem.h"
#import "IMBaseAttribute.h"
#import "PlacehodeTextView.h"

@class IMChatToolBar, IMBaseItem;
@protocol IMChatToolBarDelegate <NSObject>
/**
 *  刷新消息
 */
- (void)IMChatToolBar:(IMChatToolBar *)schoolChatToolBar imBaseItem:(IMBaseItem *)messageItem;
/**
 *  发送多条
 *
 *  @param schoolChatToolBar 
 *  @param messageItem       消息体
 */
- (void)IMChatToolBar:(IMChatToolBar *)schoolChatToolBar sendIMBaseItem:(IMBaseItem *)messageItem;

/*
 *  键盘弹出  更新外部高度
 */
- (void)IMChatToolBar:(IMChatToolBar *)schoolChatToolBar ReloadHeight:(CGFloat)reloadHeight;

@end

@interface IMChatToolBar : UIView

@property(nonatomic, copy)void(^moreButtonClickBlock)();

@property(nonatomic, weak)id<IMChatToolBarDelegate> delegate;

@property(nonatomic, weak)PlacehodeTextView *inputTextView;

- (instancetype)initWithFrame:(CGRect)frame toolBarHeight:(CGFloat)toolBarHeight moreViewHeight:(CGFloat)moreViewHeight;

- (void)backOriginalHeight;

- (void)hide;

- (void)show;

@end
