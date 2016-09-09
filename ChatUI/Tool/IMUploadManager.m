//
//  IMUploadManager.m
//  qygt
//
//  Created by 周发明 on 16/8/10.
//  Copyright © 2016年 途购. All rights reserved.
//

#import "IMUploadManager.h"
#import "IMBaseAttribute.h"

/*
 http://115.236.185.26:8083/Help/Api/POST-api-UpLoadFile-UploadImage_access_token    http://115.236.185.26:8083/Help/Api/POST-api-UpLoadFile-UploadVideo_access_token   http://115.236.185.26:8083/Help/Api/POST-api-UpLoadFile-UploadAudio_access_token 上传用这个把都在同一台服务器上.我新建的站点
 */

#define UPLOAD_BASE_URL @"http://115.236.185.26:8083/"

#define UPLOAD_IMAGE_URL @"api/UpLoadFile/UploadImage?access_token="

#define UPLOAD_AUDIO_URL @"api/UpLoadFile/UploadAudio?access_token="

#define UPLOAD_VEDIO_URL @"api/UpLoadFile/UploadVideo?access_token="

#define UPLOAD_ID @"3178"

@implementation IMUploadManager

+ (void)uploadImage:(NSString *)imagePath finishBlock:(IMUploadManagerFinishBlock)finishBlock{
    
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    if (imageData.length / 1000.0 > 100) {
        CGFloat scale = 100 / (imageData.length / 1000.0);
        imageData = UIImageJPEGRepresentation(image, scale);
    }
    
    NSString *fileName = [[imagePath pathComponents] lastObject];
    
    [self uploadFileWithData:imageData uploadPath:UPLOAD_IMAGE_URL uploadId:UPLOAD_ID fileName:fileName mimeType:@"image/jpeg" finishBlock:finishBlock];
}

+ (void)uploadVideo:(NSURL *)videoUrl finishBlock:(IMUploadManagerFinishBlock)finishBlock{
    
    NSData *voiceData = [NSData dataWithContentsOfURL:videoUrl];
    
    NSString *fileName = [[[videoUrl path] pathComponents] lastObject];
    
    [self uploadFileWithData:voiceData uploadPath:UPLOAD_VEDIO_URL uploadId:UPLOAD_ID fileName:fileName mimeType:@"video/mp4" finishBlock:finishBlock];
}

+ (void)uploadAudio:(NSString *)audioUrl finishBlock:(IMUploadManagerFinishBlock)finishBlock{
    
    NSData *audioData = [NSData dataWithContentsOfFile:audioUrl];
    
    NSString *fileName = [[audioUrl pathComponents] lastObject];
    
    [self uploadFileWithData:audioData uploadPath:UPLOAD_AUDIO_URL uploadId:UPLOAD_ID fileName:fileName mimeType:@"audio/mp3" finishBlock:finishBlock];
}

+ (void)uploadFileWithData:(NSData *)data uploadPath:(NSString *)uploadPath uploadId:(NSString *)uploadID  fileName:(NSString *)fileName mimeType:(NSString *)mimeType finishBlock:(IMUploadManagerFinishBlock)finishBlock{
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[UPLOAD_BASE_URL stringByAppendingString:[NSString stringWithFormat:@"%@%@",uploadPath,uploadID]] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:mimeType];
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSProgress *progress = nil;
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error == nil){
            id obj = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            IMUploadReponseModel *model = [IMUploadReponseModel modelWithDict:obj];
            if (model.err_code == 0) {
                IMUploadReturnModel *returnModel = [IMUploadReturnModel modelWithDict:model.data];
                finishBlock(returnModel);
            } else {
                NSLog(@"上传失败");
            }
        } else {
            NSLog(@"%@", error);
        }
    }];
    
    IMUploadProgressDelegate *progressDelegate = [[IMUploadProgressDelegate alloc] init];
    
    [progress addObserver:progressDelegate forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
    
    [[IMBaseAttribute shareIMBaseAttribute].uploadProgressDict setValue:progressDelegate forKey:fileName];
    
    [uploadTask resume];
    
}

@end

@implementation IMUploadReponseModel

+ (instancetype)modelWithDict:(NSDictionary *)dict{
    
    IMUploadReponseModel *model = [[IMUploadReponseModel alloc] init];
    
    model.err_code = [dict[@"err_code"] integerValue];
    
    model.err_desc = dict[@"err_desc"];
    
    if (dict[@"data"]) {
        model.data = dict[@"data"];
    }
    
    return model;
}

@end

@implementation IMUploadReturnModel

+ (instancetype)modelWithDict:(NSDictionary *)dict{
    
    IMUploadReturnModel *model = [[IMUploadReturnModel alloc] init];
    
    model.url = dict[@"url"];
    
    if (dict[@"thumbnailUrl"]) {
        model.thumbnailUrl = dict[@"thumbnailUrl"];
    }
    
    if (dict[@"coverImage"]) {
        model.coverImage = dict[@"coverImage"];
    }
    
    if (dict[@"length"]) {
        model.length = [NSString stringWithFormat:@"%@", dict[@"length"]];
    }
    
    return model;
}

- (void)setUrl:(NSString *)url{
    _url = [UPLOAD_BASE_URL stringByAppendingString:url];
}

- (void)setThumbnailUrl:(NSString *)thumbnailUrl{
    _thumbnailUrl = [UPLOAD_BASE_URL stringByAppendingString:thumbnailUrl];
}

- (void)setCoverImage:(NSString *)coverImage{
    _coverImage = [UPLOAD_BASE_URL stringByAppendingString:coverImage];
}

@end

@implementation IMUploadProgressDelegate

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(NSProgress *)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([change[@"new"] floatValue] == 1) {
        [object removeObserver:self forKeyPath:keyPath];
    }
    if (self.progressBlock) {
        self.progressBlock([change[@"new"] floatValue]);
    }
}

+ (instancetype)uploadProgressDelegateWithKey:(NSString *)key{
    id obj = [[IMBaseAttribute shareIMBaseAttribute].uploadProgressDict valueForKey:key];
    
    if (obj && [obj isKindOfClass:[self class]]) {
        return obj;
    } else {
        return nil;
    }
}

@end

