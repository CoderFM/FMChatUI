//
//  IMImagePickerManager.m
//  qygt
//
//  Created by 周发明 on 16/8/10.
//  Copyright © 2016年 途购. All rights reserved.
//

#import "IMImagePickerManager.h"
#import "IMBaseAttribute.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface IMImagePickerManager ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property(nonatomic, assign)ImagePickerSouceType souceType;

@property(nonatomic, copy)IMImagePickerFinishAction finishAction;

@end

static IMImagePickerManager *_manager;

@implementation IMImagePickerManager

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[IMImagePickerManager alloc] init];
    });
    return _manager;
}

+ (void)showImagePickerWithSouceType:(ImagePickerSouceType)souceType withViewController:(UIViewController *)viewController finishAction:(IMImagePickerFinishAction)finishAction{
    [IMImagePickerManager shareInstance].souceType = souceType;
    [IMImagePickerManager shareInstance].finishAction = finishAction;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = [IMImagePickerManager shareInstance];
    switch (souceType) {
        case ImagePickerSoucePhotoType:
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        case ImagePickerSouceCameraType:
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.mediaTypes = @[(NSString *)kUTTypeImage];
            break;
        case ImagePickerSouceVedioType:
            picker.sourceType = UIImagePickerControllerCameraCaptureModeVideo;
            picker.mediaTypes = @[(NSString *)kUTTypeMovie];
            picker.videoMaximumDuration = 10;
            break;
        default:
            break;
    }
    
    [viewController presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    if (self.souceType == ImagePickerSouceVedioType){
        NSString *mediaType = info[UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
            
            NSURL *videoURL = info[UIImagePickerControllerMediaURL];
            
            // 视频封面写入沙盒
            UIImage *coverImage = [self getVideoPreViewImageWithVideoPath:videoURL];
            NSData *data = UIImageJPEGRepresentation(coverImage, 1.0f);
            NSString *fileName = [NSString stringWithFormat:@"coverImage%d%d.jpg", (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
            NSString *picturePath = [NSString stringWithFormat:@"%@/%@", [IMBaseAttribute dataPicturePath],fileName];
            [data writeToFile:picturePath atomically:YES];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:fileName forKey:IMTakeVedioCoverImageKey];
            // video url:
            // file:///private/var/mobile/Applications/B3CDD0B2-2F19-432B-9CFA-158700F4DE8F/tmp/capture-T0x16e39100.tmp.9R8weF/capturedvideo.mp4
            // we will convert it to mp4 format
            NSURL *mp4 = [self _convert2Mp4:videoURL];
            [dict setObject:mp4 forKey:IMTakeVedioURLKey];
            NSFileManager *fileman = [NSFileManager defaultManager];
            if ([fileman fileExistsAtPath:videoURL.path]) {
                NSError *error = nil;
                [fileman removeItemAtURL:videoURL error:&error];
                if (error) {
                    NSLog(@"failed to remove file, error:%@.", error);
                }
            }
            if (self.finishAction){
                self.finishAction(dict);
            }
        }
    } else {
        UIImage *image = info[UIImagePickerControllerEditedImage];
        if (image == nil) {
            image = [self fixOrientation:[info objectForKey:UIImagePickerControllerOriginalImage]];
        }
        
        NSData *data = UIImageJPEGRepresentation(image, 1.0f);
        if ((data.length / 1000) > 100){
            CGFloat scale = 100 / (data.length / 1000 * 1.0);
            data = UIImageJPEGRepresentation(image, scale);
        }
        
        NSString *fileName = [NSString stringWithFormat:@"%d%d.jpg", (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
        NSString *picturePath = [NSString stringWithFormat:@"%@/%@", [IMBaseAttribute dataPicturePath],fileName];
        [data writeToFile:picturePath atomically:YES];
        if (self.finishAction) {
            self.finishAction(fileName);
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];

}

- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}
    
- (NSURL *)_convert2Mp4:(NSURL *)movUrl
{
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetHighestQuality];
        NSString *mp4Path = [NSString stringWithFormat:@"%@/%d%d.mp4", [IMBaseAttribute dataVedioPath], (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
        mp4Url = [NSURL fileURLWithPath:mp4Path];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    if ([[NSFileManager defaultManager] fileExistsAtPath:movUrl.path]) {
                        [[NSFileManager defaultManager] removeItemAtURL:movUrl error:nil];
                    }
                    NSLog(@"completed.");
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        if (wait) {
            wait = nil;
        }
    }
    
    return mp4Url;
}

- (UIImage*) getVideoPreViewImageWithVideoPath:(NSURL *)videoPath;
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoPath options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *img = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return img;
}

@end
