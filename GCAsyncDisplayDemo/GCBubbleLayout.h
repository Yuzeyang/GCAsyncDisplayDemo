//
//  GCBubbleLayout.h
//  TextLayoutDemo
//
//  Created by 宫城 on 16/6/24.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *GCTypeText = @"text";            // 文本

@class GCTextLayout,GCMessageModel;
@interface GCBubbleLayout : NSObject

@property (nonatomic, strong) GCTextLayout *textLayout;

@property (nonatomic, strong) GCMessageModel *message;
@property (nonatomic, strong) NSString *messageType;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat width;

+ (instancetype)bubbleLayoutWithMessage:(GCMessageModel *)message;

@end
