//
//  NSString+AES.h
//  qygt
//
//  Created by 周发明 on 16/8/16.
//  Copyright © 2016年 途购. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (AES)

- (NSData *)AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv;

- (NSData *)AES128EncryptWithKey:(NSString *)key iv:(NSString *)iv;

@end
