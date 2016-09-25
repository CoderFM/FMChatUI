//
//  IMTableViewCell.m
//  qygt
//
//  Created by 周发明 on 16/8/4.
//  Copyright © 2016年 途购. All rights reserved.
//

#import "IMBaseCell.h"
#import "Masonry.h"
#import "IMBaseAttribute.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "IMAudioTool.h"
#import "IMUploadManager.h"
#import "IMDownloadManager.h"
#import "IMPhotoBrowseController.h"
#import "IMSQLiteTool.h"
#import "ProgressView.h"
#import "YZTextAttachment.h"
#import "YZEmotionManager.h"
#import "IMEmoticonConverter.h"
#import "UIAlertViewBlock.h"
#import <UIImageView+WebCache.h>

@interface IMBaseCell ()

@property(nonatomic, weak)UILabel *nameLabel;

@property(nonatomic, weak)UILabel *nameInfoLabel;

@property(nonatomic, weak)UIImageView *headImageView;

@property(nonatomic, weak)IMBufferView *bufferView;

@property(nonatomic, weak)UIImageView *readImageView;

@property(nonatomic, weak)UIView *timeView;

@property(nonatomic, weak)UILabel *timeLabel;

@property(nonatomic, weak)UIImageView *bgImageView;

@property(nonatomic, weak)UITextView *textView;

@property(nonatomic, weak)UIImageView *contentImageView;

@property(nonatomic, weak)UIImageView *voiceImageView;

@property(nonatomic, weak)UILabel *voiceTimeLabel;

@property(nonatomic, weak)UIActivityIndicatorView *smallIndicatorView;

@property(nonatomic, weak)UIActivityIndicatorView *bigIndicatorView;

@property(nonatomic, weak)ProgressView *progressView;

@property(nonatomic, weak)UIImageView *voiceReadStateImageView;

@property(nonatomic, weak)UIImageView *vedioStateImageView;

@property(nonatomic, weak)UIButton *clickButton;

@property(nonatomic, weak)UIButton *reSendButton;



@end

@implementation IMBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.contentView.backgroundColor = UIColorFromRGB(0xf7f7f7);
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.style = IMBaseCellDefaultStyle;
        
        [self timeView];
        
        [self nameLabel];
            
        [self nameInfoLabel];
        
        [self headImageView];
        
        [self bufferView];
        
        [self bgImageView];
        
        [self textView];
        
        [self contentImageView];
        
        [self voiceImageView];
        
        [self voiceTimeLabel];
        
        [self smallIndicatorView];
        
        [self bigIndicatorView];
        
        [self progressView];
        
        [self voiceReadStateImageView];
        
        [self vedioStateImageView];
        
        [self clickButton];
        
        [self reSendButton];
        
        [self setUpClick];
            
    }
    return self;
}

- (void)reSendButtonClick{
    WeakSelf
    [[UIAlertViewBlock shareUIAlertViewBlock] alertWithTitle:@"提示" message:@"确定重发吗?" cancelButtonTitle:@"取消" okButtonTitle:@"确定" withOkBlock:^{
        if ([weakSelf.delegate respondsToSelector:@selector(IMBaseCell:reSendMessage:)]) {
            self.messageItem.sendState = IMMessageSending;
            [weakSelf.delegate IMBaseCell:weakSelf reSendMessage:weakSelf.messageItem];
        }
    }];
}

- (void)setMessageItem:(IMBaseItem *)messageItem{
    
    _messageItem = messageItem;
    
    [self.bufferView bringSubviewToFront:self.clickButton];
    
    [self setUpSenderInfo];
    
    [self setBufferView];
    
    if (self.messageItem.sendState == IMMessageSendFail) {
        self.reSendButton.hidden = NO;
    } else {
        self.reSendButton.hidden = YES;
    }
    
    if (self.messageItem.isShowTime) {
        
    }
    
    switch (messageItem.messageBody.type) {
            
        case IMMessageTextType:
            [self setTextCell];
            break;
            
        case IMMessagePictureType:
            [self setPictureCell];
            break;
            
        case IMMessageAudioType:
            [self setAudioCell];
            break;
            
        case IMMessageVideoType:
            [self setVideoCell];
            break;
        default:
            break;
    }
    
}

- (void)setUpClick{
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bufferViewTap:)];
    
    [self.bufferView addGestureRecognizer:tap];
    
}

- (void)bufferViewTap:(UITapGestureRecognizer *)tap{
    
    switch (self.messageItem.messageType) {
        case IMMessagePictureType:
            [self clickImageCell];
            break;
            
        case IMMessageAudioType:
            [self clickVoiceCell];
            break;
            
        case IMMessageVideoType:
            [self clickVideoCell];
            break;
        default:
            break;
    }
}
#pragma mark - 消息体点击事件
- (void)cellBufferButtonClick{
    
    switch (self.messageItem.messageType) {
        case IMMessageTextType:
            [self.bufferView longPress:nil];
            break;
        case IMMessagePictureType:
            [self clickImageCell];
            break;
            
        case IMMessageAudioType:
            [self clickVoiceCell];
            break;
            
        case IMMessageVideoType:
            [self clickVideoCell];
            break;
        default:
            break;
    }
}

#pragma mark - 设置消息发送者的头像名字等
- (void)setUpSenderInfo{
    
    self.nameLabel.text = self.messageItem.senderNickName;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:self.messageItem.senderAvatarThumb] placeholderImage:[UIImage imageNamed:@"wh80"]];
    
}

#pragma mark - 设置消息体View位置
- (void)setBufferView{
    
    if (self.messageItem.isShowTime) {
        self.timeView.hidden = NO;
        self.timeLabel.text = [self handleTimeString:self.messageItem.messageTime];
        [self.timeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.contentView);
            make.height.equalTo(@([IMBaseAttribute shareIMBaseAttribute].timeViewHeight));
        }];
    } else {
        self.timeView.hidden = YES;
        [self.timeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.contentView);
            make.height.equalTo(@0);
        }];
    }
    
    if (self.style == IMBaseCellLeftStyle){
        
        [self.bufferView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.headImageView.mas_right).offset([IMBaseAttribute shareIMBaseAttribute].contentTextInsetMargin);
            make.top.equalTo(self.nameLabel.mas_bottom).offset([IMBaseAttribute shareIMBaseAttribute].contentTextInsetMargin);
            make.height.equalTo(@(self.messageItem.messageBody.bodyHeight + [IMBaseAttribute shareIMBaseAttribute].contentTextInsetMargin * 2));
            make.width.equalTo(@(self.messageItem.messageBody.bodyWidth + [IMBaseAttribute shareIMBaseAttribute].contentTextInsetMargin * 2));
        }];
        
    } else {
        [self.bufferView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.headImageView.mas_left).offset(-[IMBaseAttribute shareIMBaseAttribute].contentTextInsetMargin);
            make.top.equalTo(self.nameLabel.mas_bottom).offset([IMBaseAttribute shareIMBaseAttribute].contentTextInsetMargin);
            make.height.equalTo(@(self.messageItem.messageBody.bodyHeight + [IMBaseAttribute shareIMBaseAttribute].contentTextInsetMargin * 2));
            make.width.equalTo(@(self.messageItem.messageBody.bodyWidth + [IMBaseAttribute shareIMBaseAttribute].contentTextInsetMargin * 2));
        }];
        
    }
}

#pragma mark - 设置文本Cell
- (void)setTextCell{
    self.contentImageView.hidden = YES;
    self.textView.hidden = NO;
    self.voiceImageView.hidden = YES;
    self.voiceTimeLabel.hidden = YES;
    self.progressView.hidden = YES;
    self.voiceReadStateImageView.hidden = YES;
    self.vedioStateImageView.hidden = YES;
    
    self.textView.attributedText = [IMEmoticonConverter emoticonConverterWithInputString:self.messageItem.messageBody.messageText];
    
    self.bufferView.originalText = self.messageItem.messageBody.messageText;
    
    if (self.messageItem.sendState == IMMessageSending) {
        [self.smallIndicatorView startAnimating];
    } else {
        [self.smallIndicatorView stopAnimating];
    }
    
}
#pragma mark - 设置图片Cell
- (void)setPictureCell{
    self.contentImageView.hidden = NO;
    self.textView.hidden = YES;
    self.voiceImageView.hidden = YES;
    self.voiceTimeLabel.hidden = YES;
    self.progressView.hidden = YES;
    self.voiceReadStateImageView.hidden = YES;
    self.vedioStateImageView.hidden = YES;
    
    if (self.messageItem.messageBody.image) {
        self.contentImageView.image = self.messageItem.messageBody.image;
    } else if (self.messageItem.messageBody.locationPath != nil && self.messageItem.messageBody.locationPath.length > 0) {
        UIImage *image = [UIImage imageWithContentsOfFile:[[IMBaseAttribute dataPicturePath] stringByAppendingPathComponent:self.messageItem.messageBody.locationPath]];
        self.contentImageView.image = image;
    } else {
        self.contentImageView.image = [UIImage imageNamed:@"wh300"];
    }
    
    if (self.messageItem.sendState == IMMessageSending) {
        if (self.messageItem.uploadProgress > 0) {
            [self.bigIndicatorView stopAnimating];
            self.progressView.hidden = NO;
            self.progressView.progressValue = self.messageItem.uploadProgress;
        } else if (self.messageItem.uploadProgress == 1){
            self.progressView.hidden = YES;
            [self.bigIndicatorView startAnimating];
        } else {
            [self.bigIndicatorView startAnimating];
        }
    } else {
        [self.bigIndicatorView stopAnimating];
    }
}

#pragma mark - 设置音频Cell
- (void)setAudioCell{
    self.contentImageView.hidden = YES;
    self.textView.hidden = YES;
    self.voiceImageView.hidden = NO;
    self.progressView.hidden = YES;
    self.vedioStateImageView.hidden = YES;
    self.voiceTimeLabel.text = [NSString stringWithFormat:@"%2lu''", (unsigned long)self.messageItem.messageBody.voiceSeconds];
    if (self.messageItem.sendState == IMMessageSendSuccess) {
        self.voiceTimeLabel.hidden = NO;
    } else {
        self.voiceTimeLabel.hidden = YES;
    }
    
    if (self.messageItem.sendState == IMMessageSending) {
        [self.smallIndicatorView startAnimating];
    } else {
        [self.smallIndicatorView stopAnimating];
    }
    
    if (self.messageItem.messageBody.locationPath != nil && self.messageItem.messageBody.locationPath.length > 0) {
        self.voiceReadStateImageView.hidden = YES;
    } else {
        self.voiceReadStateImageView.hidden = NO;
    }
    
    if (self.messageItem.isPlaying) {
        [self.voiceImageView startAnimating];
    } else {
        [self.voiceImageView stopAnimating];
    }
}

#pragma mark - 设置视频Cell
- (void)setVideoCell{
    
    self.contentImageView.hidden = NO;
    self.textView.hidden = YES;
    self.voiceImageView.hidden = YES;
    self.voiceTimeLabel.hidden = YES;
    self.progressView.hidden = YES;
    self.voiceReadStateImageView.hidden = YES;
    self.vedioStateImageView.hidden = NO;
    
    if (self.messageItem.messageBody.image) {
        self.contentImageView.image = self.messageItem.messageBody.image;
    } else {
        if (self.messageItem.messageBody.coverImage != nil && self.messageItem.messageBody.coverImage.length > 0) {
            UIImage *image = [UIImage imageWithContentsOfFile:[[IMBaseAttribute dataPicturePath] stringByAppendingPathComponent:self.messageItem.messageBody.coverImage]];
            self.contentImageView.image = image;
        }
    }
    
    if (self.messageItem.isDownloading){
        if (self.messageItem.downloadProgress > 0) {
            [self.bigIndicatorView stopAnimating];
        } else {
            [self.bigIndicatorView startAnimating];
        }
        self.progressView.hidden = NO;
        self.progressView.progressValue = self.messageItem.downloadProgress;
        self.vedioStateImageView.hidden = YES;
    } else if (self.messageItem.sendState == IMMessageSending){
        self.vedioStateImageView.hidden = YES;
        if (self.messageItem.uploadProgress > 0) {
            [self.bigIndicatorView stopAnimating];
            self.progressView.hidden = NO;
            self.progressView.progressValue = self.messageItem.uploadProgress;
        } else if (self.messageItem.uploadProgress == 1){
            self.progressView.hidden = YES;
            [self.bigIndicatorView startAnimating];
        } else {
            [self.bigIndicatorView startAnimating];
        }
    } else {
        [self.bigIndicatorView stopAnimating];
        self.progressView.hidden = YES;
        self.vedioStateImageView.hidden = NO;
        if (self.messageItem.messageBody.locationPath != nil && self.messageItem.messageBody.locationPath.length > 0) {
            self.vedioStateImageView.image = [UIImage imageNamed:@"school_chat_vedio_play"];
        } else {
            self.vedioStateImageView.image = [UIImage imageNamed:@"school_chat_vedio_download"];
        }
    }
    
}

#pragma mark - 设置整体Cell样式
- (void)setStyle:(IMBaseCellStyle)style{
    
    if (_style == style || style == IMBaseCellDefaultStyle) return;
    
    _style = style;
    
    if (style == IMBaseCellLeftStyle) {
        
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(65);
            make.top.equalTo(self.timeView.mas_bottom);
        }];
        
        [self.nameInfoLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel.mas_right).offset(10);
            make.centerY.equalTo(self.nameLabel.mas_centerY);
        }];
        
        [self.headImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(10);
            make.left.equalTo(@10);
            make.width.height.equalTo(@([IMBaseAttribute shareIMBaseAttribute].headImageViewWidth));
        }];
        
        UIImage *image = [UIImage imageNamed:@"school_chat_student_leftbg"];
        image = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.7];
        self.bgImageView.image = image;
        
        [self.bgImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.top.bottom.equalTo(self.bufferView);
            make.left.equalTo(self.bufferView).offset(-5);
        }];
        
        self.voiceImageView.image = [UIImage imageNamed:@"school_chat_left_playaudio3"];
        self.voiceImageView.animationImages = @[[UIImage imageNamed:@"school_chat_left_playaudio1"], [UIImage imageNamed:@"school_chat_left_playaudio2"], [UIImage imageNamed:@"school_chat_left_playaudio3"]];
        
        [self.voiceImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bufferView.mas_centerY);
            make.left.equalTo(self.bufferView).equalTo(@10);
        }];
        
        [self.voiceTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.bufferView.mas_bottom).offset(-5);
            make.left.equalTo(self.bufferView.mas_right).offset(5);
        }];
        
        [self.smallIndicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bufferView.mas_centerY);
            make.left.equalTo(self.bufferView.mas_right).offset(5);
        }];
        
        [self.voiceReadStateImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.bufferView).offset(2);
            make.top.equalTo(self.bufferView).offset(-2);
        }];
        
        [self.reSendButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bufferView.mas_right).offset(3);
            make.centerY.equalTo(self.bufferView);
            make.width.height.equalTo(@21);
        }];
        
    } else {
        
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-65);
            make.top.equalTo(self.timeView.mas_bottom);
        }];
        
        [self.nameInfoLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.nameLabel.mas_left).offset(-10);
            make.centerY.equalTo(self.nameLabel.mas_centerY);
        }];
        
        [self.headImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(10);
            make.right.equalTo(@(-10));
            make.width.height.equalTo(@([IMBaseAttribute shareIMBaseAttribute].headImageViewWidth));
        }];
        UIImage *image = [UIImage imageNamed:@"school_chat_student_rightbg"];
        image = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.7];
        self.bgImageView.image = image;
        [self.bgImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(self.bufferView);
            make.right.equalTo(self.bufferView).offset(5);
        }];
        
        self.voiceImageView.image = [UIImage imageNamed:@"school_chat_right_playaudio3"];
        self.voiceImageView.animationImages = @[[UIImage imageNamed:@"school_chat_right_playaudio1"], [UIImage imageNamed:@"school_chat_right_playaudio2"], [UIImage imageNamed:@"school_chat_right_playaudio3"]];
        [self.voiceImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bufferView.mas_centerY);
            make.right.equalTo(self.bufferView).equalTo(@-10);
        }];
        
        [self.voiceTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.bufferView.mas_bottom).offset(-5);
            make.right.equalTo(self.bufferView.mas_left).offset(-5);
        }];
        
        [self.smallIndicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bufferView.mas_centerY);
            make.right.equalTo(self.bufferView.mas_left).offset(-5);
        }];
        
        [self.voiceReadStateImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bufferView).offset(-2);
            make.top.equalTo(self.bufferView).offset(-2);
        }];
        
        [self.reSendButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.bufferView.mas_left).offset(-3);
            make.centerY.equalTo(self.bufferView);
            make.width.height.equalTo(@21);
        }];
    }
    
}

#pragma mark - 消息体的点击事件

#pragma mark - 图片
- (void)clickImageCell{
    
    if (self.messageItem.messageBody.locationPath && self.messageItem.messageBody.locationPath.length > 0) {
      
        IMPhotoBrowseController *photo = [[IMPhotoBrowseController alloc] init];
        photo.imagePath = [[IMBaseAttribute dataPicturePath] stringByAppendingPathComponent:self.messageItem.messageBody.locationPath];
        
        CGRect newRect = [self.contentImageView convertRect:self.contentImageView.bounds toView:[UIApplication sharedApplication].keyWindow];
        photo.smallImageFrame = newRect;
        photo.smallImage = self.contentImageView.image;
        
        
        UINavigationController *na = [[UINavigationController alloc] initWithRootViewController:photo];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            na.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        else
        {
            na.modalPresentationStyle=UIModalPresentationCurrentContext;
        }
        
        if ([self.delegate respondsToSelector:@selector(IMBaseCell:presentViewController:animated:completion:)]) {
            [self.delegate IMBaseCell:self presentViewController:na animated:NO completion:nil];
        }
        
    } else {
        if  (self.messageItem.messageBody.imageUrlString.length > 0){
            NSString *fileName = [NSString stringWithFormat:@"%d%d.jpg", (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
            self.messageItem.messageBody.locationPath = fileName;
            [IMSQLiteTool updateMessage:self.messageItem withKey:@"messageBody"];
            IMPhotoBrowseController *photo = [[IMPhotoBrowseController alloc] init];
            photo.imageURLPath = self.messageItem.messageBody.imageUrlString;
            photo.imageFileName = fileName;
            CGRect newRect = [self.contentImageView convertRect:self.contentImageView.bounds toView:[UIApplication sharedApplication].keyWindow];
            photo.smallImageFrame = newRect;
            photo.smallImage = self.contentImageView.image;
            UINavigationController *na = [[UINavigationController alloc] initWithRootViewController:photo];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
            {
                na.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            }
            else
            {
                na.modalPresentationStyle=UIModalPresentationCurrentContext;
            }
            if ([self.delegate respondsToSelector:@selector(IMBaseCell:presentViewController:animated:completion:)]) {
                [self.delegate IMBaseCell:self presentViewController:na animated:NO completion:nil];
            }
        } else {
            NSLog(@"查看失败");
        }
    }
}
#pragma mark - 音频
- (void)clickVoiceCell{
    
    if ([self.delegate respondsToSelector:@selector(IMBaseCellClickAudioCell:)]) {
        [self.delegate IMBaseCellClickAudioCell:self];
    }
}
#pragma mark - 视频
- (void)clickVideoCell{
    
    if (self.messageItem.messageBody.locationPath && self.messageItem.messageBody.locationPath.length > 0) {
        
        NSString *path = [[IMBaseAttribute dataVedioPath] stringByAppendingPathComponent:self.messageItem.messageBody.locationPath];
        
        
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        
        if (version > 9.0){
            
            AVPlayerViewController *playerView = [[AVPlayerViewController alloc] init];
            
            AVPlayer *player = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:path]];
            
            playerView.player = player;
            
            if ([self.delegate respondsToSelector:@selector(IMBaseCell:presentViewController:animated:completion:)]) {
                [self.delegate IMBaseCell:self presentViewController:playerView animated:YES completion:^{
                    [playerView.player play];
                }];
            }
            
        } else {
            
            MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
            
            if ([self.delegate respondsToSelector:@selector(IMBaseCell:presentViewController:animated:completion:)]) {
                [self.delegate IMBaseCell:self presentViewController:player animated:YES completion:nil];
            }
        }
        
    } else {
        
        NSString *fileName = [NSString stringWithFormat:@"%d%d.mp4", (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
        
        if ([IMDownloadProgressDelegate downloadProgressDelegateWithKey:fileName]) return;
        
        self.messageItem.isDownloading = YES;
        self.messageItem = self.messageItem;
        
        WeakSelf
        [IMDownloadManager downLoadFileUrl:self.messageItem.messageBody.videoUrl datePath:[IMBaseAttribute dataVedioPath] fileName:fileName completionHandler:^(BOOL isSuccess) {
            self.messageItem.isDownloading = NO;
            weakSelf.messageItem = weakSelf.messageItem;
            if (isSuccess) {
                weakSelf.messageItem.messageBody.locationPath = fileName;
                [IMSQLiteTool updateMessage:weakSelf.messageItem withKey:@"messageBody"];
                MainQueueBlock(^{
                    [weakSelf setVideoCell];
                })
            } else {
                NSLog(@"下载失败");
            }
        }];
        
        [[IMDownloadProgressDelegate downloadProgressDelegateWithKey:fileName] setProgressBlock:^(CGFloat progress) {
            weakSelf.messageItem.downloadProgress = progress;
            MainQueueBlock(^{
                [weakSelf setVideoCell];
            })
        }];
    }
}

#pragma mark - 处理时间显示

- (NSString *)handleTimeString:(NSString *)timeString{
    // 2016-08-16 19:48:18
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *messageDate = [formatter dateFromString:timeString];
    NSDate *currentDate = [NSDate date];
    NSString *currnetDateString = [formatter stringFromDate:currentDate];
    currnetDateString = [currnetDateString substringToIndex:10];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSDate *todayDate = [formatter dateFromString:currnetDateString];
    
    NSTimeInterval todayInterval = [currentDate timeIntervalSinceDate:todayDate];
    
    NSTimeInterval interval = [currentDate timeIntervalSinceDate:messageDate];
    
    NSTimeInterval oneDayInterval = 24 * 60 * 60;
    
    if (interval < todayInterval) {// 今天
        return [timeString substringWithRange:NSMakeRange(11, 5)];
    } else if (interval < (todayInterval + oneDayInterval)){// 昨天
        return [NSString stringWithFormat:@"昨天 %@", [timeString substringWithRange:NSMakeRange(11, 5)]];
    } else if (interval < (todayInterval + oneDayInterval * 2)){// 前天
        return [NSString stringWithFormat:@"前天 %@", [timeString substringWithRange:NSMakeRange(11, 5)]];
    } else {
        return [NSString stringWithFormat:@"%@", [timeString substringWithRange:NSMakeRange(5, 11)]];
    }
}

#pragma mark - getter

- (UIView *)timeView{
    if (_timeView == nil) {
    
        UIView *timeView = [[UIView alloc] init];
        
        timeView.backgroundColor = self.contentView.backgroundColor;
        
        timeView.clipsToBounds = YES;
        
        [self.contentView addSubview:timeView];
        
        _timeView = timeView;
        
        [_timeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.contentView);
            make.height.equalTo(@40);
        }];
        
        UILabel *timeLabel = [[UILabel alloc] init];
        
        timeLabel.textColor = [UIColor whiteColor];
        
        timeLabel.font = [UIFont systemFontOfSize:12];
        
        [_timeView addSubview:timeLabel];
        
        _timeLabel = timeLabel;
        
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_timeView);
        }];
        
        UIView *backView = [[UIView alloc] init];
        
        backView.layer.cornerRadius = 5;
        
        backView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
        
        [_timeView insertSubview:backView atIndex:0];
        
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(_timeLabel).offset(-5);
            make.right.bottom.equalTo(_timeLabel).offset(5);
        }];
        
    }
    return _timeView;
}

- (UILabel *)nameLabel{
    
    if (_nameLabel == nil) {
        
        UILabel *nameLabel = [[UILabel alloc] init];
        
        nameLabel.font = [IMBaseAttribute shareIMBaseAttribute].nameLabelFont;
        
        nameLabel.textColor = [IMBaseAttribute shareIMBaseAttribute].nameLabelTextColor;
        
        [self.contentView addSubview:nameLabel];
        
        _nameLabel = nameLabel;
        
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(65);
            make.top.equalTo(self.timeView.mas_bottom).offset(20);
        }];
        
    }
    return _nameLabel;
}

- (UILabel *)nameInfoLabel{
    
    if (_nameInfoLabel == nil) {
        
        UILabel *nameInfoLabel = [[UILabel alloc] init];
        
        nameInfoLabel.font = [IMBaseAttribute shareIMBaseAttribute].nameInfoLabelFont;
        
        nameInfoLabel.textColor = [IMBaseAttribute shareIMBaseAttribute].nameInfoLabelTextColor;
        
        [self.contentView addSubview:nameInfoLabel];
        
        _nameInfoLabel = nameInfoLabel;
        
        [_nameInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel.mas_right).offset(10);
            make.centerY.equalTo(self.nameLabel.mas_centerY);
        }];
        
    }
    return _nameInfoLabel;
}

- (UIImageView *)headImageView{
    
    if (_headImageView == nil) {
        
        UIImageView *headImageView = [[UIImageView alloc] init];
        
        headImageView.layer.cornerRadius = [IMBaseAttribute shareIMBaseAttribute].headImageViewCornerRadius;
        
        headImageView.layer.masksToBounds  = YES;
        
        headImageView.layer.borderColor = [UIColor colorWithRed:241 / 255.0 green:241 / 255.0 blue:241 / 255.0 alpha:1].CGColor;
        
        headImageView.layer.borderWidth = 1;
        
        [self.contentView addSubview:headImageView];
        
        _headImageView = headImageView;
        
        [_headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(10);
            make.left.equalTo(@10);
            make.width.height.equalTo(@([IMBaseAttribute shareIMBaseAttribute].headImageViewWidth));
        }];
    }
    return _headImageView;
}

- (IMBufferView *)bufferView{
    
    if (_bufferView == nil) {
        
        IMBufferView *buffer = [[IMBufferView alloc] init];
        
        buffer.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:buffer];
        
        _bufferView = buffer;
        
        [_bufferView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.headImageView.mas_right).offset(10);
            make.top.equalTo(self.nameLabel.mas_bottom).offset(10);
            make.right.equalTo(self.contentView.mas_right).offset(-30);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
        }];
        
    }
    return _bufferView;
}

- (UIImageView *)bgImageView{
    
    if (_bgImageView == nil) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
        
        imageView.image = [UIImage imageNamed:@"school_chat_student_leftbg"];
        
        [self.bufferView addSubview:imageView];
        
        _bgImageView = imageView;
        
        UIImage *image = [UIImage imageNamed:@"school_chat_student_leftbg"];
        
        image = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.7];
        _bgImageView.image = image;
        
        [_bgImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.top.bottom.equalTo(self.bufferView);
            make.left.equalTo(self.bufferView).offset(-5);
        }];
        
    }
    return _bgImageView;
}

- (UITextView *)textView{
    
    if (_textView == nil) {
        
        UITextView *textView = [[UITextView alloc] init];
        
        textView.backgroundColor = [UIColor clearColor];
        
        textView.font = [IMBaseAttribute shareIMBaseAttribute].contentTextFont;
        
        textView.textColor = [IMBaseAttribute shareIMBaseAttribute].contentTextColor;
        
        [self.bufferView addSubview:textView];
        
        _textView = textView;
        
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@2);
            make.left.equalTo(@([IMBaseAttribute shareIMBaseAttribute].contentTextInsetMargin * 0.8));
            make.right.equalTo(@(-[IMBaseAttribute shareIMBaseAttribute].contentTextInsetMargin * 0.8));
            make.bottom.equalTo(@0);
        }];
    }
    return _textView;
}

- (UIImageView *)contentImageView{
    
    if (_contentImageView == nil) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.layer.cornerRadius = 5;
        imageView.layer.masksToBounds = YES;
        [self.bufferView addSubview:imageView];
        
        _contentImageView = imageView;
        [_contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self.bufferView).offset(3);
            make.right.bottom.equalTo(self.bufferView).offset(-3);
        }];
    }
    return _contentImageView;
}

- (UIImageView *)voiceImageView{
    if (_voiceImageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.bufferView addSubview:imageView];
        _voiceImageView = imageView;
        _voiceImageView.animationDuration = 1.5;
        _voiceImageView.animationRepeatCount = 0;
        _voiceImageView.image = [UIImage imageNamed:@"school_chat_left_playaudio3"];
        _voiceImageView.animationImages = @[[UIImage imageNamed:@"school_chat_left_playaudio1"], [UIImage imageNamed:@"school_chat_left_playaudio2"], [UIImage imageNamed:@"school_chat_left_playaudio3"]];
        [_voiceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bufferView.mas_centerY);
            make.left.equalTo(self.bufferView).equalTo(@10);
        }];
    }
    return _voiceImageView;
}

- (UILabel *)voiceTimeLabel{
    if (_voiceTimeLabel == nil) {
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [IMBaseAttribute shareIMBaseAttribute].nameInfoLabelTextColor;
        label.font = [IMBaseAttribute shareIMBaseAttribute].nameInfoLabelFont;
        [self.contentView addSubview:label];
        _voiceTimeLabel = label;
        
        [_voiceTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.bufferView.mas_bottom);
            make.left.equalTo(self.bufferView.mas_right).offset(10);
        }];
    }
    return _voiceTimeLabel;
}

- (UIActivityIndicatorView *)smallIndicatorView{
    if (_smallIndicatorView == nil) {
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:view];
        _smallIndicatorView = view;
        [_smallIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bufferView.mas_centerY);
            make.left.equalTo(self.bufferView.mas_right);
        }];
    }
    return _smallIndicatorView;
}

- (UIActivityIndicatorView *)bigIndicatorView{
    if (_bigIndicatorView == nil) {
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.bufferView addSubview:view];
        _bigIndicatorView = view;
        [self.bigIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bufferView.mas_centerY);
            make.centerX.equalTo(self.bufferView.mas_centerX);
        }];
    }
    return _bigIndicatorView;
}

- (ProgressView *)progressView{
    if (_progressView == nil) {
        
        ProgressView *progressView = [[ProgressView alloc] init];
        
        progressView.backgroundColor = [UIColor clearColor];
        
        [self.bufferView addSubview:progressView];
        
        _progressView = progressView;
        
        [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.bufferView);
            make.width.equalTo(@40);
            make.height.equalTo(@40);
        }];
    }
    return _progressView;
}

- (UIImageView *)voiceReadStateImageView{
    if (_voiceReadStateImageView == nil) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
        
        imageView.image = [UIImage imageNamed:@"school_chat_not_read"];
        
        [self.bufferView addSubview:imageView];
        
        _voiceReadStateImageView = imageView;
        
        [_voiceReadStateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.bufferView);
            make.top.equalTo(self.bufferView);
        }];
    }
    return _voiceReadStateImageView;
}

- (UIImageView *)vedioStateImageView{
    if (_vedioStateImageView == nil) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
        
        imageView.image = [UIImage imageNamed:@"school_chat_vedio_download"];
        
        [self.bufferView addSubview:imageView];
        
        _vedioStateImageView = imageView;
        
        [_vedioStateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.bufferView);
            make.width.equalTo(@40);
            make.height.equalTo(@40);
        }];
    }
    return _vedioStateImageView;
}

- (UIButton *)clickButton{
    
    if (_clickButton == nil) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [btn addTarget:self action:@selector(cellBufferButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        [self.bufferView addSubview:btn];
        
        _clickButton = btn;
        
        [_clickButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.top.equalTo(self.bufferView);
        }];
    }
    return _clickButton;
}

- (UIButton *)reSendButton{
    if (_reSendButton == nil) {
        
        UIButton *btn = [[UIButton alloc] init];
        
        [btn setBackgroundImage:[UIImage imageNamed:@"school_chat_sendfail"] forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(reSendButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:btn];
        
        _reSendButton = btn;
        
        [_reSendButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bufferView.mas_right).offset(3);
            make.centerY.equalTo(self.bufferView);
            make.width.height.equalTo(@21);
        }];
    }
    return _reSendButton;
}

@end

@implementation IMBufferView

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        
        self.userInteractionEnabled = YES;
        
        [self addGestureRecognizer:longPress];
        
    }
    return self;
}

- (void)longPress:(UILongPressGestureRecognizer *)longPress{
    
    // 让label成为第一响应者
    [self becomeFirstResponder];
    
    // 获得菜单
    UIMenuController *menu = [UIMenuController sharedMenuController];
    
    // 菜单最终显示的位置
    [menu setTargetRect:CGRectMake(0, 5, self.bounds.size.width, self.bounds.size.height) inView:self];
    
    // 显示菜单
    [menu setMenuVisible:YES animated:YES];
    
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

/**
 * 通过第一响应者的这个方法告诉UIMenuController可以显示什么内容
 */
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if ( (action == @selector(copy:) && self.originalText) ) return YES;
    
    return NO;
}

- (void)copy:(UIMenuController *)menu
{
    // 将label的文字存储到粘贴板
    [UIPasteboard generalPasteboard].string = self.originalText;
}


@end

