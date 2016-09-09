//
//  IMUploadManager.h
//  qygt
//
//  Created by 周发明 on 16/8/10.
//  Copyright © 2016年 途购. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@class IMUploadReturnModel;
typedef void(^IMUploadManagerFinishBlock)(IMUploadReturnModel *model);
@interface IMUploadManager : NSObject

+ (void)uploadImage:(NSString *)imagePath finishBlock:(IMUploadManagerFinishBlock)finishBlock;

+ (void)uploadVideo:(NSURL *)videoUrl finishBlock:(IMUploadManagerFinishBlock)finishBlock;

+ (void)uploadAudio:(NSString *)audioUrl finishBlock:(IMUploadManagerFinishBlock)finishBlock;

@end

@interface IMUploadReponseModel : NSObject

@property(nonatomic, assign)NSInteger err_code;

@property(nonatomic, copy)NSString *err_desc;

@property(nonatomic, strong)NSDictionary *data;

+ (instancetype)modelWithDict:(NSDictionary *)dict;

@end

@interface IMUploadReturnModel : NSObject

@property(nonatomic, copy)NSString *url;

@property(nonatomic, copy)NSString *thumbnailUrl;

@property(nonatomic, copy)NSString *length;

@property(nonatomic, copy)NSString *coverImage;

+ (instancetype)modelWithDict:(NSDictionary *)dict;

@end

@interface IMUploadProgressDelegate : NSObject

@property(nonatomic, copy)void(^progressBlock)(CGFloat progress);

+ (instancetype)uploadProgressDelegateWithKey:(NSString *)key;

@end
