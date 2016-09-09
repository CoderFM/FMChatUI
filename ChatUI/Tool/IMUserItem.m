//
//  IMUserItem.m
//  qygt
//
//  Created by 周发明 on 16/8/16.
//  Copyright © 2016年 途购. All rights reserved.
//

#import "IMUserItem.h"
#import "GTMBase64.h"
#import "NSData+AES.h"

#define DecryptKey @"1234567890ABCDEF"
#define DecryptIV @"1234567890123456"

@implementation IMUserItem

+ (instancetype)userWithDcit:(NSDictionary *)dict{
    
    IMUserItem *item = [[IMUserItem alloc] init];
    
    item.FI = dict[@"FI"];
    
    item.GNN = dict[@"GNN"];
    
    item.NN = dict[@"NN"];
    
    return item;
}

- (void)setFI:(NSString *)FI{
    _FI = [[self class] senderIDWithDecodeString:FI];
}

+ (NSString *)senderIDWithDecodeString:(NSString *)decodeString{
    
    NSString *string = [NSString stringWithFormat:@"%@", decodeString];
    
    NSData *data = [GTMBase64 decodeString:string];
    
    data = [data AES128DecryptWithKey:DecryptKey iv:DecryptIV];
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSString *)encodeString:(NSString *)string{
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    data = [data AES128EncryptWithKey:DecryptKey iv:DecryptIV];

    return [GTMBase64 stringByEncodingData:data];
}

@end
