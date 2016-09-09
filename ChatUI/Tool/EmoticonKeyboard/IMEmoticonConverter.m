//
//  IMEmoticonConverter.m
//  qygt
//
//  Created by 周发明 on 16/8/26.
//  Copyright © 2016年 途购. All rights reserved.
//

#import "IMEmoticonConverter.h"
#import "YZEmotionManager.h"
#import "IMBaseAttribute.h"

@implementation IMEmoticonConverter

+ (NSMutableAttributedString *)emoticonConverterWithInputString:(NSString *)inputString{
    
    __block NSString *input = inputString;
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:inputString];
    
    [attr addAttribute:NSFontAttributeName value:[IMBaseAttribute shareIMBaseAttribute].contentTextFont range:NSMakeRange(0, input.length)];
    
    [attr addAttribute:NSForegroundColorAttributeName value:[IMBaseAttribute shareIMBaseAttribute].contentTextColor range:NSMakeRange(0, input.length)];
    
    [[self emoticonStrings] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSRange range1 = [input rangeOfString:obj];
    
        while (range1.location != NSNotFound) {
            
            NSString *str1 = [obj substringWithRange:NSMakeRange(1, obj.length - 1)];
            
            NSString *imageName = [NSString stringWithFormat:@"%03d", ([str1 intValue] + 1)];
            
            imageName = [NSString stringWithFormat:@"Emotion.bundle/%@", imageName];
            
            NSTextAttachment *Attachment = [[NSTextAttachment alloc] init];
            
            Attachment.image = [UIImage imageNamed:imageName];
            
            Attachment.bounds = CGRectMake(0, -3, 18, 18);
            
            NSAttributedString *textAttachmentString = [NSAttributedString attributedStringWithAttachment:Attachment];
            
            [attr deleteCharactersInRange:range1];
            
            [attr insertAttributedString:textAttachmentString atIndex:range1.location];
            
            input = [input stringByReplacingCharactersInRange:range1 withString:@" "];
            
            range1 = [input rangeOfString:obj];
            
        }
        
    }];
    
    return attr;
}

+ (NSArray<NSString *> *)emoticonStrings{
    NSMutableArray *arrM = [NSMutableArray array];
    for (int i = 0; i < 106; i++) {
        
        [arrM addObject:[NSString stringWithFormat:@"[%d]", i]];
        
    }
    return [NSArray arrayWithArray:arrM];
}

+ (NSString *)emoticonsWithInputString:(NSString *)inputString{
    
    __block NSString *input = inputString;
    
    [[self emoticonStrings] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSRange range1 = [input rangeOfString:obj];
        
        while (range1.location != NSNotFound) {
            
            input = [input stringByReplacingCharactersInRange:range1 withString:@"Nii"];
            
            range1 = [input rangeOfString:obj];
            
        }
        
    }];
    
    return input;
    
}

@end
