//
//  IMUserItem.h
//  qygt
//
//  Created by 周发明 on 16/8/16.
//  Copyright © 2016年 途购. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMUserItem : NSObject

/*
 A = "";
 FI = "jZOSbDwOdjm5FhBYUnHLJA==";
 G = 0;
 GI = 57ad67c7f67cd622fc61dcd1;
 GNN = "\U7ba1\U7406\U5458";
 ID = 0;
 IGO = 1;
 NN = "\U7ba1\U7406\U5458";
 V = 1;
 */

@property(nonatomic, copy)NSString *FI;

@property(nonatomic, copy)NSString *GNN;

@property(nonatomic, copy)NSString *NN;

+ (instancetype)userWithDcit:(NSDictionary *)dict;

+ (NSString *)senderIDWithDecodeString:(NSString *)decodeString;

+ (NSString *)encodeString:(NSString *)string;

@end
