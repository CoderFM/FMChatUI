//
//  IMEmoticonConverter.h
//  qygt
//
//  Created by 周发明 on 16/8/26.
//  Copyright © 2016年 途购. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMEmoticonConverter : NSObject

+ (NSMutableAttributedString *)emoticonConverterWithInputString:(NSString *)inputString;

+ (NSString *)emoticonsWithInputString:(NSString *)inputString;

@end
