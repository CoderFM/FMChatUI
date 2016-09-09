//
//  LiveChatMoreView.m
//  qygt
//
//  Created by 周发明 on 16/6/21.
//  Copyright © 2016年 途购. All rights reserved.
//

#import "IMChatMoreView.h"

@interface IMChatMoreView ()


@property (weak, nonatomic) IBOutlet UIView *lineView;


@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;

@end


@implementation IMChatMoreView

+ (instancetype)viewForXib{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
}

+ (instancetype)viewForXibAndDelegate:(id<IMChatMoreViewDelegate>)delegate{
    
    IMChatMoreView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
    
    view.delegate = delegate;
    
    return view;
}

- (IBAction)photoButtonClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(IMChatMoreViewPhotoButtonClick:)]) {
        [self.delegate IMChatMoreViewPhotoButtonClick:self];
    }
}

- (IBAction)cameraButtonClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(IMChatMoreViewCameraButtonClick:)]) {
        [self.delegate IMChatMoreViewCameraButtonClick:self];
    }
}
- (IBAction)videoButtonClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(IMChatMoreViewVideoButtonClick:)]) {
        [self.delegate IMChatMoreViewVideoButtonClick:self];
    }
}

- (void)awakeFromNib{
    
    self.backgroundColor = UIColorFromRGB(0xf7f7f7);
    self.lineView.backgroundColor = UIColorFromRGB(0xcccccc);
    
    [self.labels enumerateObjectsUsingBlock:^(UILabel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.textColor = UIColorFromRGB(0x878787);
    }];
}

@end
