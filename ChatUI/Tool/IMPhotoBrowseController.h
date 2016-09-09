//
//  IMPhotoBrowseController.h
//  qygt
//
//  Created by 周发明 on 16/8/15.
//  Copyright © 2016年 途购. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMBaseItem.h"

@interface IMPhotoBrowseController : UIViewController

@property(nonatomic, strong)NSString *imagePath;

@property(nonatomic, strong)NSString *imageURLPath;

@property(nonatomic, strong)NSString *imageFileName;

@property(nonatomic, strong)IMBaseItem *message;

@property(nonatomic, strong)UIImage *smallImage;

@property(nonatomic, assign)CGRect smallImageFrame;

@end

@interface IMBigImageCache : NSObject

+ (void)storeImage:(UIImage *)image WithKey:(NSString *)key;

+ (UIImage *)imageWithKey:(NSString *)key;

@end