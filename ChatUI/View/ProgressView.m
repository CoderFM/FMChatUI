//
//  ProgressView.m
//  qygt
//
//  Created by 周发明 on 16/8/19.
//  Copyright © 2016年 途购. All rights reserved.
//

#import "ProgressView.h"
#import "Masonry.h"

@interface ProgressView ()

@property(nonatomic, weak)UILabel *progressLabel;

@end


@implementation ProgressView

- (void)drawRect:(CGRect)rect {
    
    CGFloat redio = 5;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();//获取上下文
    
    CGPoint center = CGPointMake(rect.size.width * 0.5, rect.size.height * 0.5);  //设置圆心位置
    CGFloat radius = rect.size.width * 0.5 - redio;  //设置半径
    CGFloat startA = - M_PI_2;  //圆起点位置
    CGFloat endA = -M_PI_2 + M_PI * 2 * self.progressValue;  //圆终点位置
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];
    
    CGContextSetLineWidth(ctx, redio); //设置线条宽度
    [[UIColor whiteColor] setStroke]; //设置描边颜色
    
    CGContextAddPath(ctx, path.CGPath); //把路径添加到上下文
    
    CGContextStrokePath(ctx);  //渲染
    
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        UILabel *label = [[UILabel alloc] init];
        
        [self addSubview:label];
        
        label.font = [UIFont systemFontOfSize:11];
        
        label.textColor = [UIColor whiteColor];
        
        label.textAlignment = NSTextAlignmentCenter;
        
        self.progressLabel = label;
        
        [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        
    }
    return self;
}

- (void)setProgressValue:(CGFloat)progressValue{
    _progressValue = progressValue;
    self.progressLabel.text = [NSString stringWithFormat:@"%2d", (int)(progressValue * 100)];
    [self setNeedsDisplay];
}

@end