//
//  PlacehodeTextView.h
//  qygt
//
//  Created by 周发明 on 16/4/18.
//  Copyright © 2016年 赵越. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlacehodeTextView : UITextView

@property(nonatomic,copy) NSString *myPlaceholder;  //文字

@property(nonatomic,strong) UIColor *myPlaceholderColor; //文字颜色

- (void)alinmentCenterY;

@end
