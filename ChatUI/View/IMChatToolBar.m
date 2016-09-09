//
//  SchoolChatToolBar.m
//  qygt
//
//  Created by 周发明 on 16/8/4.
//  Copyright © 2016年 途购. All rights reserved.
//

#import "IMChatToolBar.h"
#import "PlacehodeTextView.h"
#import "Masonry.h"
#import "IMImagePickerManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "IMUploadManager.h"
#import "IMVoiceVolumeView.h"
#import "IMSQLiteTool.h"
#import "YZEmotionKeyboard.h"
#import "YZTextAttachment.h"
#import "UITextView+YZEmotion.h"

@interface IMChatToolBar ()<UITextViewDelegate, IMChatMoreViewDelegate>

@property(nonatomic, weak)UIButton *recordButton;

@property(nonatomic, weak)UIButton *moreButton;

@property(nonatomic, weak)UIButton *emoticonButton;

@property(nonatomic, weak)UIButton *audioButton;

@property(nonatomic, weak)IMChatMoreView *moreView;

@property(nonatomic, weak)UIView *toolBarView;

@property(nonatomic, assign)CGFloat toolBarHeight;

@property(nonatomic, assign)CGFloat moreViewHeight;

@property(nonatomic, weak)UIView *recordView;

@property(nonatomic, weak)UIViewController *viewController;

@property(nonatomic, weak)IMVoiceVolumeView *volumeView;

@property(nonatomic, weak)YZEmotionKeyboard *emotionKeyboard;

@end

@implementation IMChatToolBar

- (instancetype)initWithFrame:(CGRect)frame toolBarHeight:(CGFloat)toolBarHeight moreViewHeight:(CGFloat)moreViewHeight{
    
    if (self = [super initWithFrame:frame]) {
        
        self.toolBarHeight = toolBarHeight;
        self.moreViewHeight = moreViewHeight;
        
        self.backgroundColor = UIColorFromRGB(0xe3e3e3);
        
        CGFloat btnW = 30;
        CGFloat emoticonButtonW = 30;
        CGFloat emoticonButtonRightMargin = 10;
        
        [self.toolBarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.equalTo(@(toolBarHeight));
        }];
        
        [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self.toolBarView).offset(5);
            make.bottom.equalTo(self.toolBarView).offset(-5);
            make.width.equalTo(@(btnW));
        }];
        
        [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.toolBarView).offset(-emoticonButtonRightMargin);
            make.bottom.equalTo(self.toolBarView).offset(-5);
            make.top.equalTo(self.toolBarView).offset(5);
            make.width.equalTo(@(emoticonButtonW));
        }];
        
        [self.emoticonButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.moreButton.mas_left).offset(-5);
            make.top.equalTo(self.toolBarView).offset(5);
            make.bottom.equalTo(self.toolBarView).offset(-5);
            make.width.equalTo(@(btnW));
        }];
        
        [self.inputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.recordButton.mas_right).offset(5);
            make.right.equalTo(self.emoticonButton.mas_left).offset(-10);
            make.top.equalTo(self.toolBarView).offset(10);
            make.bottom.equalTo(self.toolBarView).offset(-10);
        }];
        
        [self.audioButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.top.equalTo(self.inputTextView);
        }];
        
        
        [self.moreView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.toolBarView.mas_bottom);
            make.left.right.equalTo(self);
            make.height.equalTo(@(moreViewHeight));
        }];
        
        
        [self volumeView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
    }
    
    return self;
}

- (void)recordButtonClick{
    self.recordButton.selected = !self.recordButton.isSelected;
    self.audioButton.hidden = !self.recordButton.isSelected;
    if (self.recordButton.isSelected) {
        self.emoticonButton.selected = NO;
        self.moreButton.selected = NO;
        self.inputTextView.yz_emotionKeyboard = nil;
        [self.inputTextView resignFirstResponder];
        [self backOriginalHeight];
    } else {
        [self.inputTextView becomeFirstResponder];
    }
}

- (void)moreButtonClick{
    self.emoticonButton.selected = NO;
    [self.inputTextView resignFirstResponder];
    self.moreButton.selected = !self.moreButton.isSelected;
    if (!self.moreButton.isSelected) {
        CGRect frame = self.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height - self.toolBarHeight;
        if ([self.delegate respondsToSelector:@selector(IMChatToolBar:ReloadHeight:)]) {
            [self.delegate IMChatToolBar:self ReloadHeight:0];
        }
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = frame;
        } completion:^(BOOL finished) {

        }];
    } else {
        self.inputTextView.yz_emotionKeyboard = nil;
        CGRect frame = self.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height - self.toolBarHeight - self.moreViewHeight;
        if ([self.delegate respondsToSelector:@selector(IMChatToolBar:ReloadHeight:)]) {
            [self.delegate IMChatToolBar:self ReloadHeight:self.moreViewHeight];
        }
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = frame;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)emoticonButtonClick{
    
    self.emoticonButton.selected = !self.emoticonButton.isSelected;
    
    if (self.emoticonButton.selected) {
        self.audioButton.hidden = YES;
        self.recordButton.selected = NO;
        self.inputTextView.yz_emotionKeyboard = self.emotionKeyboard;
        [self.inputTextView becomeFirstResponder];
    } else {
        self.inputTextView.yz_emotionKeyboard = nil;
        [self reloadInputViews];
    }
}
// 开始录音
- (void)recordButtonTouchDown
{
    [self.volumeView volunmeViewNormal];
    self.volumeView.hidden = NO;
    self.audioButton.backgroundColor = [UIColor colorWithRed:200 / 255.0 green:200 / 255.0 blue:200 / 255.0 alpha:1];
    
    WeakSelf
    [[IMAudioTool shareAudioTool] recorderVoiceVolumeView:self.volumeView finishBlock:^(NSString *audioPath, CGFloat seconds) {
        if (audioPath.length > 0) {
            
            if (seconds > 1) {
                
                if (seconds >= IMAudioMaxDurtion){
                    [weakSelf.volumeView showLongTimeModel];
                } else {
                    weakSelf.volumeView.hidden = YES;
                }
                
                weakSelf.audioButton.backgroundColor = [UIColor whiteColor];
                
                IMBaseItem *item = [IMBaseItem itemMessageVoicePath:audioPath seconds:seconds];
                
                [item setUpWithOtherInfo];
                
//                item.sendState = IMMessageSending;
                
                if ([weakSelf.delegate respondsToSelector:@selector(IMChatToolBar:imBaseItem:)]) {
                    [weakSelf.delegate IMChatToolBar:self imBaseItem:item];
                }
                
//                [IMUploadManager uploadAudio:[[IMBaseAttribute dataAudioPath] stringByAppendingPathComponent:audioPath] finishBlock:^(IMUploadReturnModel *model) {
//                    
//                    item.messageBody.voiceUrlString = model.url;
//                    
//                    item.messageBody.locationPath = audioPath;
//                    
//                    [self sendMessage:item];
//                }];
                
            } else {
                [weakSelf.volumeView showShortTimeModel];
            }
        }
    }];
}
// 取消录音
- (void)recordButtonTouchUpOutside// 滑出  并不在按钮上
{
    [[IMAudioTool shareAudioTool] recorderStop];
    self.volumeView.hidden = YES;
    self.audioButton.backgroundColor = [UIColor whiteColor];
}
// 完成录音
- (void)recordButtonTouchUpInside
{
//    self.volumeView.hidden = YES;
    [[IMAudioTool shareAudioTool] startEncode];
    self.audioButton.backgroundColor = [UIColor whiteColor];
}
// 滑出按钮  但按钮还在响应点击事件
- (void)recordDragOutside
{
    [self.volumeView volunmeViewCancel];
    self.audioButton.backgroundColor = [UIColor colorWithRed:200 / 255.0 green:200 / 255.0 blue:200 / 255.0 alpha:1];
}
// 滑入按钮范围
- (void)recordDragInside
{
    [self.volumeView volunmeViewNormal];
    self.audioButton.backgroundColor = [UIColor colorWithRed:200 / 255.0 green:200 / 255.0 blue:200 / 255.0 alpha:1];
}

- (void)keyboardWillShow:(NSNotification *)noti{
    
    self.moreButton.selected = NO;
    
    CGRect rect = [[noti.userInfo objectForKey:@"UIKeyboardBoundsUserInfoKey"]   CGRectValue];
    
    CGFloat height = SCREEN_HEIGHT - rect.size.height - self.toolBarHeight;
    
    CGRect frame = self.frame;
    
    frame.origin.y = height;

    if ([self.delegate respondsToSelector:@selector(IMChatToolBar:ReloadHeight:)]) {
        [self.delegate IMChatToolBar:self ReloadHeight:rect.size.height];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillHide:(NSNotification *)noti{
    
    self.moreButton.selected = NO;
    
    CGRect frame = self.frame;
    
    frame.origin.y = [UIScreen mainScreen].bounds.size.height - self.toolBarHeight;
    
    if ([self.delegate respondsToSelector:@selector(IMChatToolBar:ReloadHeight:)]) {
        [self.delegate IMChatToolBar:self ReloadHeight:0];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)backOriginalHeight{
    
    [self.inputTextView resignFirstResponder];
    self.emoticonButton.selected = NO;
    self.inputTextView.yz_emotionKeyboard = nil;
    
    CGRect frame = self.frame;
    
    frame.origin.y = [UIScreen mainScreen].bounds.size.height - self.toolBarHeight;
    
    if ([self.delegate respondsToSelector:@selector(IMChatToolBar:ReloadHeight:)]) {
        [self.delegate IMChatToolBar:self ReloadHeight:0];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hide{
    
    CGRect frame = self.frame;
    
    frame.origin.y = [UIScreen mainScreen].bounds.size.height;
    
    if ([self.delegate respondsToSelector:@selector(IMChatToolBar:ReloadHeight:)]) {
        [self.delegate IMChatToolBar:self ReloadHeight:0];
    }
    [UIView animateWithDuration:0.1 animations:^{
        self.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)show{
    
    CGRect frame = self.frame;
    
    frame.origin.y = [UIScreen mainScreen].bounds.size.height - self.toolBarHeight;
    
    if ([self.delegate respondsToSelector:@selector(IMChatToolBar:ReloadHeight:)]) {
        [self.delegate IMChatToolBar:self ReloadHeight:0];
    }
    [UIView animateWithDuration:0.1 animations:^{
        self.frame = frame;
    } completion:^(BOOL finished) {
        
    }];

}

- (void)sendText:(NSString *)text{
    
    if (text.length > 0){
        
        IMMessageBody *body = [[IMMessageBody alloc] initWithText:text];
        
        IMBaseItem *item = [IMBaseItem itemMessageBody:body];
        
        [item setUpWithOtherInfo];
        
//        item.sendState = IMMessageSending;
        
        if ([self.delegate respondsToSelector:@selector(IMChatToolBar:imBaseItem:)]) {
            [self.delegate IMChatToolBar:self imBaseItem:item];
        }
        
//        [self sendMessage:item];
        
        self.inputTextView.text = @"";
    }
    
}

- (NSString *)emotionText
{
    
    NSMutableString *strM = [NSMutableString string];
    
    [self.inputTextView.attributedText enumerateAttributesInRange:NSMakeRange(0, self.inputTextView.attributedText.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        NSString *str = nil;
        
        YZTextAttachment *attachment = attrs[@"NSAttachment"];
        
        if (attachment) { // 表情
            str = attachment.emotionStr;
            [strM appendString:str];
        } else { // 文字
            str = [self.inputTextView.attributedText.string substringWithRange:range];
            [strM appendString:str];
        }
        
    }];
    
    return strM;
}

- (void)sendMessage:(IMBaseItem *)message{
    if ([self.delegate respondsToSelector:@selector(IMChatToolBar:sendIMBaseItem:)]){
        [self.delegate IMChatToolBar:self sendIMBaseItem:message];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        
        [self sendText:[self emotionText]];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - IMChatMoreViewDelegate

// 照片
- (void)IMChatMoreViewPhotoButtonClick:(IMChatMoreView *)livechatmoreview{
    
    WeakSelf
    [IMImagePickerManager showImagePickerWithSouceType:ImagePickerSoucePhotoType withViewController:self.viewController finishAction:^(NSString *soucePath) {
        if (soucePath) {
            
            IMBaseItem *item = [IMBaseItem itemMessageImage:soucePath];
            
            [item setUpWithOtherInfo];
            
//            item.sendState = IMMessageSending;
            
            if ([weakSelf.delegate respondsToSelector:@selector(IMChatToolBar:imBaseItem:)]) {
                [weakSelf.delegate IMChatToolBar:weakSelf imBaseItem:item];
            }
            
//            [IMUploadManager uploadImage:[NSString stringWithFormat:@"%@/%@", [IMBaseAttribute dataPicturePath], soucePath] finishBlock:^(IMUploadReturnModel *model) {
//                
//                item.messageBody.imageUrlString = model.url;
//                item.messageBody.imageThumUrlString = model.thumbnailUrl;
//                item.messageBody.locationPath = soucePath;
//                [self sendMessage:item];
//            }];
//            
//            [[IMUploadProgressDelegate uploadProgressDelegateWithKey:soucePath] setProgressBlock:^(CGFloat progress) {
//                item.uploadProgress = progress;
//                MainQueueBlock(^{
//                    if ([weakSelf.delegate respondsToSelector:@selector(IMChatToolBar:imBaseItem:)]) {
//                        [weakSelf.delegate IMChatToolBar:weakSelf imBaseItem:item];
//                    }
//                })
//            }];
        }
    }];
}

// 拍照
- (void)IMChatMoreViewCameraButtonClick:(IMChatMoreView *)livechatmoreview{
    WeakSelf
    [IMImagePickerManager showImagePickerWithSouceType:ImagePickerSouceCameraType withViewController:self.viewController finishAction:^(NSString *soucePath) {
        if (soucePath) {
            
            IMBaseItem *item = [IMBaseItem itemMessageImage:soucePath];
            
            [item setUpWithOtherInfo];
            
//            item.sendState = IMMessageSending;
            
            if ([weakSelf.delegate respondsToSelector:@selector(IMChatToolBar:imBaseItem:)]) {
                [weakSelf.delegate IMChatToolBar:weakSelf imBaseItem:item];
            }
            
//            [IMUploadManager uploadImage:[NSString stringWithFormat:@"%@/%@", [IMBaseAttribute dataPicturePath], soucePath] finishBlock:^(IMUploadReturnModel *model) {
//                
//                item.messageBody.imageUrlString = model.url;
//                item.messageBody.imageThumUrlString = model.thumbnailUrl;
//                item.messageBody.locationPath = soucePath;
//                [self sendMessage:item];
//            }];
//            
//            [[IMUploadProgressDelegate uploadProgressDelegateWithKey:soucePath] setProgressBlock:^(CGFloat progress) {
//                MainQueueBlock(^{
//                    item.uploadProgress = progress;
//                    if ([weakSelf.delegate respondsToSelector:@selector(IMChatToolBar:imBaseItem:)]) {
//                        [weakSelf.delegate IMChatToolBar:weakSelf imBaseItem:item];
//                    }
//                })
//            }];
        }
    }];
}

// 视频
- (void)IMChatMoreViewVideoButtonClick:(IMChatMoreView *)livechatmoreview{
    
    WeakSelf
    [IMImagePickerManager showImagePickerWithSouceType:ImagePickerSouceVedioType withViewController:self.viewController finishAction:^(id soucePath) {
        if ([soucePath isKindOfClass:[NSMutableDictionary class]]) {
            NSString *coverImage = soucePath[IMTakeVedioCoverImageKey];
            NSURL *vedioUrl = soucePath[IMTakeVedioURLKey];
            NSString *fileName = [[[vedioUrl path] componentsSeparatedByString:@"/"] lastObject];
            IMBaseItem *item = [IMBaseItem itemMessageCoverImage:coverImage vedioFileName:fileName];
            [item setUpWithOtherInfo];
//            item.sendState = IMMessageSending;
            if ([weakSelf.delegate respondsToSelector:@selector(IMChatToolBar:imBaseItem:)]) {
                [weakSelf.delegate IMChatToolBar:self imBaseItem:item];
            }
            
//            [IMUploadManager uploadVideo:vedioUrl finishBlock:^(IMUploadReturnModel *model) {
//                item.messageBody.coverImage = model.coverImage;
//                item.messageBody.videoUrl = model.url;
//                item.messageBody.locationPath = fileName;
//                item.messageBody.imageUrlString = coverImage;
//                [self sendMessage:item];
//            }];
//            
//            [[IMUploadProgressDelegate uploadProgressDelegateWithKey:fileName] setProgressBlock:^(CGFloat progress) {
//                MainQueueBlock(^{
//                    item.uploadProgress = progress;
//                    if ([weakSelf.delegate respondsToSelector:@selector(IMChatToolBar:imBaseItem:)]) {
//                        [weakSelf.delegate IMChatToolBar:weakSelf imBaseItem:item];
//                    }
//                })
//            }];
        }
    }];
}

- (NSString*)dataPath
{
    NSString *dataPath = [NSString stringWithFormat:@"%@/Library/appdata/chatbuffer", NSHomeDirectory()];
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:dataPath]){
        [fm createDirectoryAtPath:dataPath
      withIntermediateDirectories:YES
                       attributes:nil
                            error:nil];
    }
    return dataPath;
}

#pragma mark - 重写setter的方法

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:backgroundColor];
    self.toolBarView.backgroundColor = backgroundColor;
    self.moreView.backgroundColor = backgroundColor;
}

- (void)setDelegate:(id<IMChatToolBarDelegate>)delegate{
    _delegate = delegate;
    self.viewController = (UIViewController *)delegate;
}

#pragma mark - 懒加载

- (UIButton *)recordButton{
    
    if (_recordButton == nil) {
        
        UIButton *record = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [record setImage:[UIImage imageNamed:@"school_chat_record"] forState:UIControlStateNormal];
        
        [record setImage:[UIImage imageNamed:@"school_chat_keybord"] forState:UIControlStateSelected];
        
        [self.toolBarView addSubview:record];
        
        [record addTarget:self action:@selector(recordButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        _recordButton = record;

    }
    return _recordButton;
}

- (PlacehodeTextView *)inputTextView{
    
    if (_inputTextView == nil) {
        
        PlacehodeTextView *inputView = [[PlacehodeTextView alloc] init];
        
        inputView.font = [UIFont systemFontOfSize:15];
        
        inputView.myPlaceholder = @"这里输入文字";
        
        inputView.backgroundColor = [UIColor whiteColor];
        
        inputView.layer.cornerRadius = 5;
        
        inputView.layer.masksToBounds = YES;
        
        [inputView alinmentCenterY];
        
        inputView.returnKeyType = UIReturnKeySend;
        
        inputView.delegate = self;
        
        [self.toolBarView addSubview:inputView];
        
        _inputTextView = inputView;
    }
    return _inputTextView;
}

- (UIButton *)audioButton{
    
    if (_audioButton == nil) {
        
        UIButton *audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        audioButton.backgroundColor = [UIColor whiteColor];
        
        [audioButton setTitle:@"按住 说话" forState:UIControlStateNormal];
        
        [audioButton setTitleColor:UIColorFromRGB(0x878787) forState:UIControlStateNormal];

        [audioButton setTitle:@"松开 结束" forState:UIControlStateHighlighted];
        
        audioButton.layer.cornerRadius = 5;
        
        audioButton.layer.masksToBounds = YES;
        
        audioButton.hidden = YES;
        
        [audioButton addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
        [audioButton addTarget:self action:@selector(recordButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
        [audioButton addTarget:self action:@selector(recordButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [audioButton addTarget:self action:@selector(recordDragOutside) forControlEvents:UIControlEventTouchDragExit];
        [audioButton addTarget:self action:@selector(recordDragInside) forControlEvents:UIControlEventTouchDragEnter];
        
        [self.toolBarView addSubview:audioButton];
        
        _audioButton = audioButton;
    }
    return _audioButton;
}

- (UIButton *)moreButton{
    
    if (_moreButton == nil) {
        
        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [moreButton setImage:[UIImage imageNamed:@"school_chat_more"] forState:UIControlStateNormal];
        
        [self.toolBarView addSubview:moreButton];
        
        [moreButton addTarget:self action:@selector(moreButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        _moreButton = moreButton;
    }
    return _moreButton;
}

- (UIButton *)emoticonButton{
    
    if (_emoticonButton == nil) {
        
        UIButton *emoticonButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [emoticonButton setImage:[UIImage imageNamed:@"school_chat_emoticon"] forState:UIControlStateNormal];
        
        [emoticonButton setImage:[UIImage imageNamed:@"school_chat_keybord"] forState:UIControlStateSelected];
        
        [emoticonButton setTitleColor:RGBColor(255, 153, 0) forState:UIControlStateNormal];
        
        [emoticonButton setTitleColor:RGBColor(153, 255, 0) forState:UIControlStateSelected];
        
        emoticonButton.titleLabel.font = [UIFont systemFontOfSize:15];
        
        [self.toolBarView addSubview:emoticonButton];
        
        [emoticonButton addTarget:self action:@selector(emoticonButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        _emoticonButton = emoticonButton;
    }
    return _emoticonButton;
}

- (IMChatMoreView *)moreView{
    
    if (_moreView == nil) {
        
        IMChatMoreView *more = [IMChatMoreView viewForXib];
        
        more.delegate = self;
        
        [self addSubview:more];
        
        _moreView = more;
    }
    return _moreView;
}

- (UIView *)toolBarView{
    
    if (_toolBarView == nil) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:view];
        _toolBarView = view;
        
    }
    return _toolBarView;
}

- (IMVoiceVolumeView *)volumeView{
    
    if (_volumeView == nil) {
        
        IMVoiceVolumeView *volumeView = [[IMVoiceVolumeView alloc] initWithFrame:CGRectMake(0, ([UIScreen mainScreen].bounds.size.height - [UIScreen mainScreen].bounds.size.width) * 0.5, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width)];
        
        volumeView.hidden = YES;
        
        [[UIApplication sharedApplication].keyWindow addSubview:volumeView];
        
        _volumeView = volumeView;
        
    }
    return _volumeView;
}

// 懒加载键盘
- (YZEmotionKeyboard *)emotionKeyboard
{
    // 创建表情键盘
    if (_emotionKeyboard == nil) {
        
        YZEmotionKeyboard *emotionKeyboard = [YZEmotionKeyboard emotionKeyboard];
        
        WeakSelf
        emotionKeyboard.sendContent = ^(NSString *content){
//             点击发送会调用，自动把文本框内容返回给你
            if (content.length > 0) {
                [weakSelf sendText:content];
            }
            
        };
        
        _emotionKeyboard = emotionKeyboard;
    }
    return _emotionKeyboard;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
