//
//  IMVoiceVolumeView.m
//  qygt
//
//  Created by 周发明 on 16/8/11.
//  Copyright © 2016年 途购. All rights reserved.
//

#import "IMVoiceVolumeView.h"
#import "Masonry.h"

#define IMVoiceViewHeight 150
#define IMVoiceViewWidth 155

@interface IMVoiceVolumeView()

@property(nonatomic, weak)UIView *contentView;

@property(nonatomic, weak)UIView *contentView1;

@property(nonatomic, weak)UIImageView *imageView1;
@property(nonatomic, weak)UIImageView *imageView2;
@property(nonatomic, weak)UIImageView *imageView3;
@property(nonatomic, weak)UIImageView *imageView4;
@property(nonatomic, weak)UIImageView *imageView5;

@property(nonatomic, weak)UILabel *label;

@property(nonatomic, weak)UIView *countDownView;

@property(nonatomic, weak)UIView *remindView;

@property(nonatomic, weak)UILabel *timerLabel;

@property(nonatomic, assign)IMVoiceVolumeViewType type;

@property(nonatomic, strong)NSTimer *countDownTimer;

@property(nonatomic, assign)NSInteger seconds;

@property(nonatomic, weak)UILabel *remindLabel;

@end

static IMVoiceVolumeView *volunmeView;

@implementation IMVoiceVolumeView

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        [self setUpContentCancelView];
        [self setUpContentNormalView];
        [self setUpCountDownView];
        [self setUpRemindView];
        
        self.seconds = 9;
    }
    return self;
}

- (void)setUpContentNormalView{
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        
        imageView.image = [UIImage imageNamed:@"school_chat_audio_bg"];
        
        [self.contentView addSubview:imageView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
    }
    
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        
        imageView.image = [UIImage imageNamed:@"school_chat_audio_mic"];
        
        [self.contentView addSubview:imageView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(41));
            make.top.equalTo(@(40));
        }];
    }
    
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        
        imageView.image = [UIImage imageNamed:@"school_chat_audio_volume1"];
        
        [self.contentView addSubview:imageView];
        
        self.imageView1 = imageView;
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-30));
            make.top.equalTo(@(58));
        }];
    }
    
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        
        imageView.image = [UIImage imageNamed:@"school_chat_audio_volume2"];
        
        [self.contentView addSubview:imageView];
        
        self.imageView2 = imageView;
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-30));
            make.top.equalTo(@(58));
        }];
    }
    
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        
        imageView.image = [UIImage imageNamed:@"school_chat_audio_volume3"];
        
        [self.contentView addSubview:imageView];
        
        self.imageView3 = imageView;
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-30));
            make.top.equalTo(@(58));
        }];
    }
    
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        
        imageView.image = [UIImage imageNamed:@"school_chat_audio_volume4"];
        
        [self.contentView addSubview:imageView];
        
        self.imageView4 = imageView;
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-30));
            make.top.equalTo(@(58));
        }];
    }
    
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        
        imageView.image = [UIImage imageNamed:@"school_chat_audio_volume5"];
        
        [self.contentView addSubview:imageView];
        
        self.imageView5 = imageView;
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-30));
            make.top.equalTo(@(58));
        }];
    }
    
    {
        UILabel *label = [[UILabel alloc] init];
        
        label.text = @"手指上滑 取消录音";
        
        label.textAlignment = NSTextAlignmentCenter;
        
        label.font = [UIFont systemFontOfSize:14];
        
        label.textColor = [UIColor colorWithWhite:1 alpha:0.5];
        
        [self.contentView addSubview:label];
        
        self.label = label;
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView).offset(-14);
            make.width.equalTo(@129);
        }];
    }
}

- (void)setUpContentCancelView{
    
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        
        imageView.image = [UIImage imageNamed:@"school_chat_audio_bg"];
        
        [self.contentView1 addSubview:imageView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView1);
        }];
    }
    
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        
        imageView.image = [UIImage imageNamed:@"school_chat_audio_cancel"];
        
        [self.contentView1 addSubview:imageView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView1);
            make.top.equalTo(self.contentView1).offset(37);
        }];
    }
    
    {
        UILabel *label = [[UILabel alloc] init];
        
        label.text = @"手指上滑 取消录音";
        
        label.textAlignment = NSTextAlignmentCenter;
        
        label.textColor = [UIColor colorWithWhite:1 alpha:0.5];
        
        label.font = [UIFont systemFontOfSize:14];
        
        label.backgroundColor = [UIColor colorWithRed:188 / 255.0 green:111 / 255.0 blue:60 / 255.0 alpha:1];
        
        [self.contentView1 addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView1);
            make.bottom.equalTo(self.contentView1).offset(-14);
            make.width.equalTo(@129);
        }];
    }

    self.contentView1.hidden = YES;
}

- (void)setUpCountDownView{
    
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        
        imageView.image = [UIImage imageNamed:@"school_chat_audio_bg"];
        
        [self.countDownView addSubview:imageView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.countDownView);
        }];
    }
    
    {
        
        UILabel *label = [[UILabel alloc] init];
        
        label.text = @"手指松开 取消录音";
        
        label.textAlignment = NSTextAlignmentCenter;
        
        label.textColor = [UIColor colorWithWhite:1 alpha:0.5];
        
        label.font = [UIFont systemFontOfSize:14];
        
        [self.countDownView addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.countDownView);
            make.bottom.equalTo(self.countDownView).offset(-14);
            make.width.equalTo(@129);
        }];
        
    }

    {
        UILabel *timerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        
        timerLabel.text = @"9";
        
        timerLabel.textColor = [UIColor whiteColor];
        
        timerLabel.font = [UIFont boldSystemFontOfSize:80];
    
        [self.countDownView addSubview:timerLabel];
        
        [timerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.countDownView);
            make.centerY.equalTo(self.countDownView.mas_centerY).offset(-10);
        }];
        
        self.timerLabel = timerLabel;
    }
    
    self.countDownView.hidden = YES;
    
}

- (void)setUpRemindView{
    
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        
        imageView.image = [UIImage imageNamed:@"school_chat_audio_bg"];
        
        [self.remindView addSubview:imageView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.remindView);
        }];
    }
    
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        
        imageView.image = [UIImage imageNamed:@"school_chat_audio_gth"];
        
        [self.remindView addSubview:imageView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.remindView);
            make.top.equalTo(self.remindView).offset(37);
        }];
    }
    
    {
        UILabel *label = [[UILabel alloc] init];
        
        label.text = @"说话时间太短";
        
        label.textAlignment = NSTextAlignmentCenter;
        
        label.textColor = [UIColor colorWithWhite:1 alpha:0.5];
        
        label.font = [UIFont systemFontOfSize:14];
        
        [self.remindView addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.remindView);
            make.bottom.equalTo(self.remindView).offset(-14);
        }];
        
        self.remindLabel = label;
    }
    
    self.remindView.hidden = YES;
}

- (void)volunmeWithSound:(CGFloat)volumn{
    
    if (volumn < -30) {
        volumn = -30;
    }
    
    if (volumn > 0) {
        volumn = 0;
    }
    
    if (volumn < -24) {// 最小声
        self.imageView1.hidden = NO;
        self.imageView2.hidden = YES;
        self.imageView3.hidden = YES;
        self.imageView4.hidden = YES;
        self.imageView5.hidden = YES;
    } else if (volumn < -18){
        self.imageView1.hidden = NO;
        self.imageView2.hidden = NO;
        self.imageView3.hidden = YES;
        self.imageView4.hidden = YES;
        self.imageView5.hidden = YES;
    } else if (volumn < -12){
        self.imageView1.hidden = NO;
        self.imageView2.hidden = NO;
        self.imageView3.hidden = NO;
        self.imageView4.hidden = YES;
        self.imageView5.hidden = YES;
    } else if (volumn < -6){
        self.imageView1.hidden = NO;
        self.imageView2.hidden = NO;
        self.imageView3.hidden = NO;
        self.imageView4.hidden = NO;
        self.imageView5.hidden = YES;
    } else {
        self.imageView1.hidden = NO;
        self.imageView2.hidden = NO;
        self.imageView3.hidden = NO;
        self.imageView4.hidden = NO;
        self.imageView5.hidden = NO;
    }
}

- (void)volunmeViewCancel{
    self.type = IMVoiceVolumeViewCancelType;
    self.contentView1.hidden = NO;
    self.countDownView.hidden = YES;
    self.contentView.hidden = YES;
    self.remindView.hidden = YES;
}

- (void)volunmeViewNormal{
    if (self.seconds < 9) {
        self.type = IMVoiceVolumeViewCountDownType;
        self.contentView1.hidden = YES;
        self.countDownView.hidden = NO;
        self.contentView.hidden = YES;
        self.remindView.hidden = YES;
    } else {
        self.type = IMVoiceVolumeViewNormalType;
        self.contentView1.hidden = YES;
        self.countDownView.hidden = YES;
        self.contentView.hidden = NO;
        self.remindView.hidden = YES;
    }
}

- (void)volunmeViewCountDown{
    if (self.type == IMVoiceVolumeViewCancelType) return;
    self.type = IMVoiceVolumeViewCountDownType;
    self.contentView1.hidden = YES;
    self.countDownView.hidden = NO;
    self.contentView.hidden = YES;
    self.remindView.hidden = YES;
}

- (void)volunmeViewCountDownBegin{
    [self volunmeViewCountDown];
    [self countDownTimer];
}

- (void)volunmeViewCountDownWithTimer:(NSInteger)countDown{
    self.timerLabel.text = [NSString stringWithFormat:@"%ld", countDown];
}

- (void)countDownTimerStart{
    [self volunmeViewCountDownWithTimer:--self.seconds];
}

- (void)showShortTimeModel{
    self.remindLabel.text = @"说话时间太短";
    [self willHideRemindView];
}

- (void)showLongTimeModel{
    self.remindLabel.text = @"说话时间过长";
    [self willHideRemindView];
}

- (void)willHideRemindView{
    self.contentView1.hidden = YES;
    self.contentView.hidden = YES;
    self.countDownView.hidden = YES;
    self.remindView.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.type = IMVoiceVolumeViewNormalType;
        [self volunmeViewNormal];
        self.hidden = YES;
    });
}

- (UIView *)contentView{
    
    if (_contentView == nil) {
        
        UIView *content = [[UIView alloc] initWithFrame:CGRectZero];
        
        [self addSubview:content];
        
        [content mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.equalTo(@(IMVoiceViewWidth));
            make.height.equalTo(@(IMVoiceViewHeight));
        }];
        
        _contentView = content;
        
    }
    return _contentView;
}

- (UIView *)contentView1{
    
    if (_contentView1 == nil) {
        
        UIView *content = [[UIView alloc] initWithFrame:CGRectZero];
        
        [self addSubview:content];
        
        [content mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.equalTo(@(IMVoiceViewWidth));
            make.height.equalTo(@(IMVoiceViewHeight));
        }];
        
        _contentView1 = content;
        
    }
    return _contentView1;
}

- (UIView *)countDownView{
    
    if (_countDownView == nil) {
        
        UIView *content = [[UIView alloc] initWithFrame:CGRectZero];
        
        [self addSubview:content];
        
        [content mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.equalTo(@(IMVoiceViewWidth));
            make.height.equalTo(@(IMVoiceViewHeight));
        }];
        
        _countDownView = content;
        
    }
    return _countDownView;
    
}

- (UIView *)remindView{
    
    if (_remindView == nil) {
        
        UIView *content = [[UIView alloc] initWithFrame:CGRectZero];
        
        [self addSubview:content];
        
        [content mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.equalTo(@(IMVoiceViewWidth));
            make.height.equalTo(@(IMVoiceViewHeight));
        }];
        
        _remindView = content;
    }
    return _remindView;
}

- (NSTimer *)countDownTimer{
    if (_countDownTimer == nil){
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(countDownTimerStart) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        _countDownTimer = timer;
        
    }
    return _countDownTimer;
}

@end
