//
//  IMBaseCellAttribute.h
//  qygt
//
//  Created by 周发明 on 16/8/5.
//  Copyright © 2016年 途购. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singler.h"
#import <UIKit/UIKit.h>

#define MainQueueBlock(block) dispatch_async(dispatch_get_main_queue(), block);

#define BackgroundThreadBlock(block) dispatch_async(dispatch_get_global_queue(0, 0), block);

#define WeakSelf __weak typeof(self)weakSelf = self;

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define RGBColor(r,g,b) [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1]

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface IMBaseAttribute : NSObject

SingleH(IMBaseAttribute)

@property(nonatomic, assign)CGFloat normalMargin;

@property(nonatomic, assign)CGFloat headImageViewWidth;

@property(nonatomic, strong)UIFont *nameLabelFont;

@property(nonatomic, strong)UIColor *nameLabelTextColor;

@property(nonatomic, strong)UIFont *nameInfoLabelFont;

@property(nonatomic, strong)UIColor *nameInfoLabelTextColor;

@property(nonatomic, strong)UIFont *contentTextFont;

@property(nonatomic, strong)UIColor *contentTextColor;

@property(nonatomic, assign)CGFloat headImageViewCornerRadius;

@property(nonatomic, assign)CGFloat bufferMaxWidth;

@property(nonatomic, assign)CGFloat contentTextInsetMargin;

@property(nonatomic, assign)CGFloat messageBodyImageWidth;

@property(nonatomic, assign)CGFloat messageBodyVoiceWidth;

@property(nonatomic, assign)CGFloat messageBodyVoiceHeight;

@property(nonatomic, assign)CGFloat messageBodyVedioHeight;

@property(nonatomic, assign)CGFloat messageBodyVedioWidth;

@property(nonatomic, assign)CGFloat timeViewHeight;

@property(nonatomic, strong)NSMutableDictionary *downloadProgressDict;

@property(nonatomic, strong)NSMutableDictionary *uploadProgressDict;

@property(nonatomic, copy)NSString *reciverID;

@property(nonatomic, assign)NSInteger part;

+ (NSString*)dataVedioPath;

+ (NSString*)dataAudioPath;

+ (NSString*)dataPicturePath;

@end
