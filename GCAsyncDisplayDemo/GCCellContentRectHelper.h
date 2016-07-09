//
//  GCCellContentRectHelper.h
//  TextLayoutDemo
//
//  Created by 宫城 on 16/7/4.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GCCellContentRectHelper : NSObject

+ (CGFloat)leftOriginX;
+ (CGFloat)rightOriginXWithContentWidth:(CGFloat)width;

@end
