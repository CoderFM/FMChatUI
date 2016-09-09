//
//  IMBaseTimeCell.m
//  qygt
//
//  Created by 周发明 on 16/8/5.
//  Copyright © 2016年 途购. All rights reserved.
//

#import "IMBaseTimeCell.h"
#import "Masonry.h"

@implementation IMBaseTimeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.contentView.backgroundColor = backcolor;
        
        UILabel *timeLabel = [[UILabel alloc] init];
        
        timeLabel.textColor = [UIColor whiteColor];
        
        timeLabel.font = [UIFont systemFontOfSize:12];
        
        [self.contentView addSubview:timeLabel];
        
        self.timeLabel = timeLabel;
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
        
        UIView *backView = [[UIView alloc] init];
        
        backView.layer.cornerRadius = 5;
        
        backView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
        
        [self.contentView insertSubview:backView atIndex:0];
        
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self.timeLabel).offset(-5);
            make.right.bottom.equalTo(self.timeLabel).offset(5);
        }];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
