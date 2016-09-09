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

- (void)IMBaseCell:(IMBaseCell *)cell presentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void(^)())completion;

- (void)IMBaseCell:(IMBaseCell *)cell reSendMessage:(IMBaseItem *)message;

- (void)IMBaseCellClickAudioCell:(IMBaseCell *)cell;

@end

@class IMBufferView;
@interface IMBaseCell : UITableViewCell

@property(nonatomic, weak)UILabel *nameLabel;

@property(nonatomic, weak)UILabel *nameInfoLabel;

@property(nonatomic, weak)UIImageView *headImageView;

@property(nonatomic, weak)IMBufferView *bufferView;

@property(nonatomic, weak)UIImageView *readImageView;

@property(nonatomic, assign)IMBaseCellStyle style;

@property(nonatomic, strong)IMBaseItem *messageItem;

@property(nonatomic, copy)void(^reloadCell)(IMBaseItem *messageItem);

@property(nonatomic, weak)id<IMBaseCellDelegate> delegate;

@end

@interface IMBufferView : UIView

@property(nonatomic, copy)NSString *originalText;

- (void)longPress:(UILongPressGestureRecognizer *)longPress;

@end
