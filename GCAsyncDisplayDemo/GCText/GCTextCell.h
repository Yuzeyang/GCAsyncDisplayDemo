//
//  GCTextCell.h
//  TextLayoutDemo
//
//  Created by 宫城 on 16/6/24.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const GCTextCellIdentifier;

@class GCBubbleLayout;

@interface GCTextCell : UITableViewCell

- (void)setLayout:(GCBubbleLayout *)layout;

@end
