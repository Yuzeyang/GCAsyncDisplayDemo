//
//  GCBubbleLayout.m
//  TextLayoutDemo
//
//  Created by 宫城 on 16/6/24.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import "GCBubbleLayout.h"
#import "GCMessageModel.h"
#import "GCTextLayout.h"

@interface GCBubbleLayout ()

@end

@implementation GCBubbleLayout

+ (instancetype)bubbleLayoutWithMessage:(GCMessageModel *)message {
    GCBubbleLayout *bubbleLayout = [[GCBubbleLayout alloc] init];
    bubbleLayout.message = message;
    bubbleLayout.messageType = message.msgType;
    if ([message.msgType isEqualToString:GCTypeText]) {
        bubbleLayout.textLayout = [[GCTextLayout alloc] initWithContent:message.content isSelf:message.isSelf];
    }
    
    return bubbleLayout;
}

- (CGFloat)height {
    if ([self.messageType isEqualToString:GCTypeText]) {
        return CGRectGetHeight(self.textLayout.textLabelFrame);
    } else {
        return 44;
    }
}

- (CGFloat)width {
    if ([self.messageType isEqualToString:GCTypeText]) {
        return CGRectGetWidth(self.textLayout.textLabelFrame);
    } else {
        return CGRectGetWidth([UIApplication sharedApplication].keyWindow.frame);
    }
}

@end
