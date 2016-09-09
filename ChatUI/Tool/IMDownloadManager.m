//
//  IMDownloadManager.m
//  qygt
//
//  Created by 周发明 on 16/8/13.
//  Copyright © 2016年 途购. All rights reserved.
//

#import "IMDownloadManager.h"
#import "IMBaseAttribute.h"

@implementation IMDownloadManager

+ (void)downLoadImageUrl:(NSString *)url datePath:(NSString *)path fileName:(NSString *)fileName completionHandler:(void (^)(NSString *))completionHandler{
    
    [self downLoadFileUrl:url datePath:path fileName:fileName completionHandler:^(BOOL isSuccess) {
        if (isSuccess) {
            completionHandler(fileName);
        }
    }];
}

+ (void)downLoadFileUrl:(NSString *)url datePath:(NSString *)path fileName:(NSString *)fileName completionHandler:(void (^)(BOOL))downloadState{
    
    path = [NSString stringWithFormat:@"%@/%@", path, fileName];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSProgress *progress = nil;
    
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:&progress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error == nil) {
            if (downloadState) {
                downloadState(YES);
            }
        } else {
            if (downloadState) {
                downloadState(NO);
            }
        }
    }];
    
    IMDownloadProgressDelegate *progressDelegate = [[IMDownloadProgressDelegate alloc] init];
    
    [progress addObserver:progressDelegate forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
    
    [[IMBaseAttribute shareIMBaseAttribute].downloadProgressDict setValue:progressDelegate forKey:fileName];
    
    [task resume];
}

@end

@implementation IMDownloadProgressDelegate

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(NSProgress *)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([change[@"new"] floatValue] == 1) {
        [object removeObserver:self forKeyPath:keyPath];
    }
    
    CGFloat progress = [change[@"new"] floatValue];
    
    if (self.progressBlock) {
        self.progressBlock(progress);
    }
    
}

+ (instancetype)downloadProgressDelegateWithKey:(NSString *)key{
    
    id obj = [[IMBaseAttribute shareIMBaseAttribute].downloadProgressDict valueForKey:key];
    
    if (obj && [obj isKindOfClass:[self class]]) {
        return obj;
    } else {
        return nil;
    }
}

@end
