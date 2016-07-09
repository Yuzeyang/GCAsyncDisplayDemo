//
//  GCCellContentRectHelper.m
//  TextLayoutDemo
//
//  Created by 宫城 on 16/7/4.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import "GCCellContentRectHelper.h"
#import "GCChatViewConfig.h"

@implementation GCCellContentRectHelper

+ (CGFloat)leftOriginX {
    return kGCAvatarMarginX + kGCAvatarWidth + kGCBubbleMarginX + kGCBubbleArrowWidth + GCCellContentLayoutMargin/2;
}

+ (CGFloat)rightOriginXWithContentWidth:(CGFloat)width {
    CGFloat x = [self leftOriginX];
    return  [UIApplication sharedApplication].keyWindow.frame.size.width - width - x;
}

@end
