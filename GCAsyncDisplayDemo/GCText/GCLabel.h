//
//  GCLabel.h
//  TextLayoutDemo
//
//  Created by 宫城 on 16/6/24.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^GCURLJumpBlock)(NSString *url);

@class GCTextLayout,GCTextCell;
@interface GCLabel : UIView

@property (nonatomic, weak) GCTextCell *cell;
@property (nonatomic, copy) GCURLJumpBlock urlJumpBlock;

- (void)setTextLayout:(GCTextLayout *)textLayout;

@end
