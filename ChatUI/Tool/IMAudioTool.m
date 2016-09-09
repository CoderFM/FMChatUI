//
//  IMAudioTool.m
//  qygt
//
//  Created by 周发明 on 16/8/9.
//  Copyright © 2016年 途购. All rights reserved.
//

#import "IMAudioTool.h"
#import "IMImagePickerManager.h"
#import "IMBaseAttribute.h"
#import <AVFoundation/AVFoundation.h>
#import "lame.h"
#import "IMVoiceVolumeView.h"

@interface IMAudioTool()<AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property(nonatomic, strong)AVAudioRecorder *audioRecorder;

@property(nonatomic, strong)AVAudioPlayer *audioPlayer;

@property(nonatomic, copy)NSString *oldFileName;

@property(nonatomic, copy)NSString *mp3FileName;

@property(nonatomic, assign)CGFloat seconds;

@property(nonatomic, strong)NSTimer *timer;

@property(nonatomic, copy)FinishEncodeBlock finishBlock;

@property(nonatomic, copy)FinishPlayBlock finishPlayBlock;

@property(nonatomic, copy)NSString *currentPlayFileName;

@property(nonatomic, assign)BOOL isCancel;

@property(nonatomic, weak)IMVoiceVolumeView *volumeView;

@property(nonatomic, strong)NSTimer *countDownTimer;

@end

static IMAudioTool *_instance;

@implementation IMAudioTool

+ (instancetype)shareAudioTool{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)playWithFileName:(NSString *)fileName returnBeforeFileName:(ReplacePlayFileName)replaceBlock withFinishBlock:(FinishPlayBlock)playFinish{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        self.finishPlayBlock = playFinish;
        
        if ([self.currentPlayFileName isEqualToString:fileName] && self.audioPlayer.isPlaying) {
            [self.audioPlayer stop];
            if (playFinish) {
                MainQueueBlock(^{
                    playFinish(YES);
                })
            }
        } else {
            if (self.audioPlayer.isPlaying) {
                if (replaceBlock) {
                    MainQueueBlock(^{
                        replaceBlock(self.currentPlayFileName);
                        
                    })
                }
            }
            self.currentPlayFileName = fileName;
            NSString *filePath = [[IMBaseAttribute dataAudioPath] stringByAppendingPathComponent:fileName];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
            
            UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
            AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                                    sizeof(sessionCategory),
                                    &sessionCategory);
            
            UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
            AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                                     sizeof (audioRouteOverride),
                                     &audioRouteOverride);
            
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            //默认情况下扬声器播放
            [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
            [audioSession setActive:YES error:nil];
            
            NSError *error = nil;
            self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
            self.audioPlayer.volume = 1.0;
            self.audioPlayer.delegate = self;
            [self.audioPlayer prepareToPlay];
            [self handleNotification:YES];
            [self.audioPlayer play];
        }

    });
}

- (void)stopPlay{
    if (self.audioPlayer.isPlaying) {
        [self.audioPlayer stop];
    }
}

#pragma mark - 监听听筒or扬声器
- (void) handleNotification:(BOOL)state
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:state]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    
    if(state)//添加监听
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification"
                                                   object:nil];
    else//移除监听
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}

//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else
    {
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

- (void)recorderVoiceVolumeView:(IMVoiceVolumeView *)volumeView finishBlock:(FinishEncodeBlock)finishBlock{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        self.isCancel = NO;
        self.seconds = 0;
        self.finishBlock = finishBlock;
        self.volumeView = volumeView;
        [self.timer invalidate];
        self.timer = nil;
        [self timer];
        
        if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending) {
            //7.0第一次运行会提示，是否允许使用麦克风
            AVAudioSession *session = [AVAudioSession sharedInstance];
            NSError *sessionError;
            //AVAudioSessionCategoryPlayAndRecord用于录音和播放
            [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
            if(session == nil)
                NSLog(@"Error creating session: %@", [sessionError description]);
            else
                [session setActive:YES error:nil];
        }
        
        NSString *fileName = [NSString stringWithFormat:@"%d%d", (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
        
        self.oldFileName = fileName;
        
        [self audioRecorderWithFileName:fileName];
        
        [self.audioRecorder record];
        
    });
    
}

- (void)recorderPause{
    if (self.audioRecorder.isRecording) {
        [self.audioRecorder pause];
    }
}

- (void)recorderStop{
    self.isCancel = YES;
    if (self.audioRecorder.isRecording) {
        [self.audioRecorder stop];
    }
}

- (void)startEncode{
    [self.timer invalidate];
    if ([self toMp3]) {
        if (self.finishBlock) {
            MainQueueBlock(^{
                self.finishBlock(self.mp3FileName, self.seconds);
                self.seconds = 0;
            })
        }
    } else {
        if (self.finishBlock) {
            MainQueueBlock(^{
                self.finishBlock(@"", 0);
                self.seconds = 0;
            })
        }
    }
}

- (BOOL) toMp3
{
    NSString *filePath =[[IMBaseAttribute dataAudioPath] stringByAppendingPathComponent:self.oldFileName];
    
    NSString *fileName = [NSString stringWithFormat:@"%d%d.mp3", (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];

    self.mp3FileName = fileName;
    
    NSString *mp3FilePath = [[IMBaseAttribute dataAudioPath] stringByAppendingPathComponent:fileName];
    
        BOOL isSuccess = NO;
        if (filePath == nil  || mp3FilePath == nil){
            return isSuccess;
        }
        NSFileManager* fileManager=[NSFileManager defaultManager];
        if([fileManager removeItemAtPath:mp3FilePath error:nil])
        {
            NSLog(@"删除");
        }
        
        @try {
            int read, write;
            
            FILE *pcm = fopen([filePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
            if (pcm) {
                fseek(pcm, 4*1024, SEEK_CUR);
                FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
                
                const int PCM_SIZE = 8192;
                const int MP3_SIZE = 8192;
                short int pcm_buffer[PCM_SIZE*2];
                unsigned char mp3_buffer[MP3_SIZE];
                
                lame_t lame = lame_init();
                lame_set_in_samplerate(lame, 11025.0);
                lame_set_VBR(lame, vbr_default);
                lame_init_params(lame);
                
                do {
                    read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
                    if (read == 0)
                        write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
                    else
                        write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                    
                    fwrite(mp3_buffer, write, 1, mp3);
                    
                } while (read != 0);
                
                lame_close(lame);
                fclose(mp3);
                fclose(pcm);
                isSuccess = YES;
            }
            //skip file header
        }
        @catch (NSException *exception) {
            NSLog(@"error");
        }
        @finally {
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
            return isSuccess;
        }
    
}

- (void)timeing{
    self.seconds += IMAudioTimeDurtion;
    [self.audioRecorder updateMeters];
    MainQueueBlock(^{
        if (self.seconds > IMAudioMaxDurtion - 9) {
            [self.volumeView volunmeViewCountDownBegin];
        }
        [self.volumeView volunmeWithSound:[self.audioRecorder averagePowerForChannel:0]];
    })
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    [self.timer invalidate];
    if (!self.isCancel) {
        [self startEncode];
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error{
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (self.finishPlayBlock){
        MainQueueBlock(^{
            self.finishPlayBlock(YES);
        })
    }
    [self handleNotification:NO];
}

- (NSTimer *)timer{
    if (_timer == nil) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:IMAudioTimeDurtion target:self selector:@selector(timeing) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        _timer = timer;
    }
    return _timer;
}

- (void)audioRecorderWithFileName:(NSString *)fileName{
    
    AVAudioSession * audioSession = [AVAudioSession sharedInstance];
    
    NSError* error1;
    
    [audioSession setCategory:AVAudioSessionCategoryRecord error: &error1];
    
    NSString *filePath =[[IMBaseAttribute dataAudioPath] stringByAppendingPathComponent:fileName];
    
            //录音设置
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc]init];
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:11025.0] forKey:AVSampleRateKey];
    //录音通道数  1 或 2
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
//    //线性采样位数  8、16、24、32
//    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityMedium] forKey:AVEncoderAudioQualityKey];
    
    NSError *error;
    //初始化
    self.audioRecorder = [[AVAudioRecorder alloc]initWithURL:[NSURL fileURLWithPath:filePath] settings:recordSetting error:&error];
    //开启音量检测
    self.audioRecorder.meteringEnabled = YES;
    [self.audioRecorder recordForDuration:(NSTimeInterval) IMAudioMaxDurtion];
    self.audioRecorder.delegate = self;
}

@end
