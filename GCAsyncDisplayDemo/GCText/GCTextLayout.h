//
//  GCTextLayout.h
//  TextLayoutDemo
//
//  Created by 宫城 on 16/6/24.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GCTextLayout : NSObject<NSCopying>

/**
 *  原始文本
 */
@property (nonatomic, copy, readonly) NSString *content;
/**
 *  是否是发送方
 */
@property (nonatomic, assign, readonly) BOOL isSelf;
/**
 *  文本显示frame
 */
@property (nonatomic, assign, readonly) CGRect textLabelFrame;
/**
 *  计算后文本
 */
@property (nonatomic, strong, readonly) NSMutableAttributedString *attributedContent;
/**
 *  html范围
 */
@property (nonatomic, assign, readonly) NSRange htmlRange;
/**
 *  html字段
 */
@property (nonatomic, copy, readonly) NSString *htmlUrl;
/**
 *  点击色
 */
@property (nonatomic, strong, readonly) UIColor *touchColor;
/**
 *  url范围数组
 */
@property (nonatomic, strong, readonly) NSMutableArray *urlRangeArray;
/**
 *  url点击色
 */
@property (nonatomic, strong, readonly) UIColor *urlColor;

- (instancetype)initWithContent:(NSString *)content isSelf:(BOOL)isSelf;

@end
