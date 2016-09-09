//
//  IMPhotoBrowseController.m
//  qygt
//
//  Created by 周发明 on 16/8/15.
//  Copyright © 2016年 途购. All rights reserved.
//

#import "IMPhotoBrowseController.h"
#import "IMDownloadManager.h"
#import "IMBaseAttribute.h"
#import "IMSQLiteTool.h"
#import "ProgressView.h"

@interface IMPhotoBrowseController ()<UIScrollViewDelegate, UIActionSheetDelegate>

@property(nonatomic, weak)UIScrollView *scrollView;

@property(nonatomic, weak)UIImageView *smallImageView;

@property(nonatomic, weak)UIImageView *imageView;

@property(nonatomic, weak)ProgressView *progressView;

@end

@implementation IMPhotoBrowseController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setUp];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (self.imagePath) {
        
        UIImage *image = [IMBigImageCache imageWithKey:[self.imagePath lastPathComponent]];
        
        if (!image) {
            image = [UIImage imageWithContentsOfFile:self.imagePath];
            [IMBigImageCache storeImage:image WithKey:[self.imagePath lastPathComponent]];
        }
        
        self.imageView.image = image;
        self.progressView.hidden = YES;
    }
    
    if (self.imageURLPath) {
        __weak typeof(self) weakSelf = self;
        [IMDownloadManager downLoadImageUrl:self.imageURLPath datePath:[IMBaseAttribute dataPicturePath] fileName:self.imageFileName completionHandler:^(NSString *fileName) {
            UIImage *image = [UIImage imageWithContentsOfFile:[[IMBaseAttribute dataPicturePath] stringByAppendingPathComponent:fileName]];
            [IMBigImageCache storeImage:image WithKey:fileName];
            weakSelf.imageView.image = image;
            weakSelf.progressView.hidden = YES;
        }];
        
        [[IMDownloadProgressDelegate downloadProgressDelegateWithKey:self.imageFileName] setProgressBlock:^(CGFloat progress) {
            MainQueueBlock((^{
                weakSelf.progressView.progressValue = progress;
            }))
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        self.imageView.frame = [UIScreen mainScreen].bounds;
    } completion:^(BOOL finished) {
        self.smallImageView.hidden = YES;
    }];
}

- (void)setUp{
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    scrollView.minimumZoomScale = 1;
    
    scrollView.maximumZoomScale = 2;
    
    scrollView.delegate = self;
    
    [self.view addSubview:scrollView];
    
    self.scrollView = scrollView;
    
    UIImageView *smallImageView = [[UIImageView alloc] initWithImage:self.smallImage];
    
    smallImageView.frame = self.smallImageFrame;
    
    [self.scrollView addSubview:smallImageView];
    
    self.smallImageView = smallImageView;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTap:)];
    
    [self.scrollView addGestureRecognizer:tap];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.smallImageView.frame];
    
    imageView.contentMode  =UIViewContentModeScaleAspectFit;
    
    [self.scrollView addSubview:imageView];
    
    imageView.userInteractionEnabled = YES;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewLongPress:)];
    
    [imageView addGestureRecognizer:longPress];
    
    self.imageView = imageView;
    
    ProgressView *progressView = [[ProgressView alloc] init];
    
    CGFloat labelWidth = 40;
    
    progressView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - labelWidth) * 0.5, ([UIScreen mainScreen].bounds.size.height - labelWidth) * 0.5, labelWidth, labelWidth);
    
    [self.view addSubview:progressView];
    
    self.progressView = progressView;
}

- (void)imageViewLongPress:(UILongPressGestureRecognizer *)longPress{
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存到手机", nil];
        
        [actionSheet showInView:self.view];
    }
}

- (void)scrollViewTap:(UITapGestureRecognizer *)tap{
    [UIView animateWithDuration:0.2 animations:^{
        [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        self.imageView.frame = self.smallImageFrame;
    } completion:^(BOOL finished) {
        [self.navigationController dismissViewControllerAnimated:NO completion:^{
            [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        }];
    }];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:@"保存到手机"]) {
        
        UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        
    }
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    if (error == nil) {
        [SVProgressHUD showSuccessWithStatus:@"保存成功"];
    }
    
}

- (void)dealloc{
    NSLog(@"图片查看销毁了....");
}

@end

@interface IMBigImageCache()<NSCacheDelegate>

@property(nonatomic, strong)NSCache *imageCache;

@end

static IMBigImageCache *imageCacheManager = nil;

@implementation IMBigImageCache

+ (instancetype)shareImageCache{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageCacheManager = [[self alloc] init];
    });
    return imageCacheManager;
}

+ (void)storeImage:(UIImage *)image WithKey:(NSString *)key{
    [[IMBigImageCache shareImageCache].imageCache setObject:image forKey:key];
}

+ (UIImage *)imageWithKey:(NSString *)key{
    UIImage *image = [[IMBigImageCache shareImageCache].imageCache objectForKey:key];
    if (image && [image isKindOfClass:[UIImage class]]) {
        return image;
    } else {
        return nil;
    }
}

- (NSCache *)imageCache{
    
    if (_imageCache == nil) {
        
        NSCache *cache = [[NSCache alloc] init];
        
        cache.delegate = self;
        
        _imageCache = cache;
        
    }
    return _imageCache;
}

+ (void)clearImages{
    [[IMBigImageCache shareImageCache].imageCache removeAllObjects];
    [IMBigImageCache shareImageCache].imageCache = nil;
}

@end
