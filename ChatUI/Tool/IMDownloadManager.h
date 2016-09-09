//
//  IMDownloadManager.h
//  qygt
//
//  Created by 周发明 on 16/8/13.
//  Copyright © 2016年 途购. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMDownloadManager : NSObject

+ (void)downLoadImageUrl:(NSString *)url datePath:(NSString *)path fileName:(NSString *)fileName completionHandler:(void(^)(NSString *thumFileName))completionHandler;

+ (void)downLoadFileUrl:(NSString *)url datePath:(NSString *)path fileName:(NSString *)fileName completionHandler:(void(^)(BOOL isSuccess))downloadState;
@end

@interface IMDownloadProgressDelegate : NSObject

@property(nonatomic, copy)void(^progressBlock)(CGFloat progress);

+ (instancetype)downloadProgressDelegateWithKey:(NSString *)key;

@end