//
//  IMBaseCellAttribute.h
//  qygt
//
//  Created by 周发明 on 16/8/5.
//  Copyright © 2016年 途购. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singler.h"

#define LoadGroupMessage @"api/IMAllocation/GetGroupMessageExt?access_token="

#define LoadGroupPeople @"api/Merge/MergeData?access_token="

#define CreatIMUser @"api/Account/RegisterOtherUser?nickName="

#define InviteUserIntoGroup @"api/Friends/JoinChatGroup?access_token="

#define LeaveGroup @"api/Friends/RemoveMemberGroup?access_token="

#define GetChatSeverIp  @"api/IMAllocation/Get?access_token="

#define ChatConnectionURL @"http://115.236.185.26:6789/"

//#define ChatConnectionURL @"http://chat03.safetree.com.cn/"

//#define ChatLoadMessage @"http://122.224.8.158:8082/"

//appapi01.safetree.com.cn

#define ChatLoadMessage @"http://appapi01.safetree.com.cn/"
//#define ChatLoadMessage @"http://chat03.safetree.com.cn/"

//http://chat03.safetree.com.cn

#define MainQueueBlock(block) dispatch_async(dispatch_get_main_queue(), block);

#define BackgroundThreadBlock(block) dispatch_async(dispatch_get_global_queue(0, 0), block);

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
