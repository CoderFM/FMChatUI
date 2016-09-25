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
- (void)IMChatToolBar:(IMChatToolBar *)chatToolBar imBaseItem:(IMBaseItem *)messageItem;
/**
 *  发送多条
 *
 *  @param schoolChatToolBar 
 *  @param messageItem       消息体
 */
- (void)IMChatToolBar:(IMChatToolBar *)chatToolBar sendIMBaseItem:(IMBaseItem *)messageItem;

/*
 *  键盘弹出  更新外部高度
 */
- (void)IMChatToolBar:(IMChatToolBar *)schoolChatToolBar ReloadHeight:(CGFloat)reloadHeight;

@end

@interface IMChatToolBar : UIView

@property(nonatomic, weak)id<IMChatToolBarDelegate> delegate;

@property(nonatomic, weak)PlacehodeTextView *inputTextView;
/**
 *  实例化一个toolBar
 *
 *  @param frame          尺寸
 *  @param toolBarHeight  toolBar的高度
 *  @param moreViewHeight 更多的View的高度
 *
 *  @return 实例
 */
- (instancetype)initWithFrame:(CGRect)frame toolBarHeight:(CGFloat)toolBarHeight moreViewHeight:(CGFloat)moreViewHeight;
/**
 *  回到最底部
 */
- (void)backOriginalHeight;
/**
 *  隐藏
 */
- (void)hide;
/**
 *  显示
 */
- (void)show;

@end
