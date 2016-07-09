//
//  GCMessageModel.h
//  GCAsyncDisplayDemo
//
//  Created by 宫城 on 16/7/9.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCMessageModel : NSObject

@property (nonatomic, strong) NSString *msgType;

@property (nonatomic, assign) BOOL isSelf;

@property (nonatomic, strong) NSString *content;

@end
