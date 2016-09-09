//
//  IMImagePickerManager.h
//  qygt
//
//  Created by 周发明 on 16/8/10.
//  Copyright © 2016年 途购. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum{
    ImagePickerSoucePhotoType,
    ImagePickerSouceCameraType,
    ImagePickerSouceVedioType
} ImagePickerSouceType;

#define IMTakeVedioCoverImageKey @"IMTakeVedioCoverImageKey"
#define IMTakeVedioURLKey @"IMTakeVedioURLKey"
#define IMTakeVedioErrorKey @"IMTakeVedioURLKey"

typedef void(^IMImagePickerFinishAction)(id souce);

@interface IMImagePickerManager : NSObject

+ (instancetype)shareInstance;

+ (void)showImagePickerWithSouceType:(ImagePickerSouceType)souceType withViewController:(UIViewController *)viewController finishAction:(IMImagePickerFinishAction)finishAction;

@end
