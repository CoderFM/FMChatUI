//
//  IMTableViewCell.h
//  qygt
//
//  Created by 周发明 on 16/8/4.
//  Copyright © 2016年 途购. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMBaseItem.h"

typedef enum{
    IMBaseCellDefaultStyle = -1,
    IMBaseCellLeftStyle,
    IMBaseCellRightStyle
} IMBaseCellStyle;

@class IMBaseCell;
@protocol IMBaseCellDelegate <NSObject>
/**
 *  点击视频,图片的代理方法
 *
 *  @param cell           点击的cell
 *  @param viewController 实例化好的控制器
 *  @param animated       是否动画过去
 *  @param completion     动画完成后要执行的代码
 */
- (void)IMBaseCell:(IMBaseCell *)cell presentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void(^)())completion;
/**
 *  重新发送(发送失败的情况下)
 */
- (void)IMBaseCell:(IMBaseCell *)cell reSendMessage:(IMBaseItem *)message;

- (void)IMBaseCellClickAudioCell:(IMBaseCell *)cell;

@end

@class IMBufferView;
@interface IMBaseCell : UITableViewCell

@property(nonatomic, assign)IMBaseCellStyle style;

@property(nonatomic, strong)IMBaseItem *messageItem;

@property(nonatomic, copy)void(^reloadCell)(IMBaseItem *messageItem);

@property(nonatomic, weak)id<IMBaseCellDelegate> delegate;

@end

@interface IMBufferView : UIView

@property(nonatomic, copy)NSString *originalText;

- (void)longPress:(UILongPressGestureRecognizer *)longPress;

@end
