//
//  GCTextCell.m
//  TextLayoutDemo
//
//  Created by 宫城 on 16/6/24.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import "GCTextCell.h"
#import "GCLabel.h"
#import "GCBubbleLayout.h"
#import "UIView+GCAddition.h"
#import "GCTextLayout.h"
#import "GCChatViewConfig.h"

NSString *const GCTextCellIdentifier = @"GCTextCellIdentifier";

@interface GCTextCustomContentView : UIView

@property (nonatomic, strong) UIImageView *bubbleImageView;
@property (nonatomic, strong) GCLabel *contentLabel;
@property (nonatomic, strong) GCBubbleLayout *layout;
@property (nonatomic, weak) GCTextCell *cell;

@end

@implementation GCTextCustomContentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (frame.size.width == 0 && frame.size.height == 0) {
        frame.size.width = [UIApplication sharedApplication].keyWindow.frame.size.width;
        frame.size.height = 1;
    }
    
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor lightGrayColor];

    self.bubbleImageView = [UIImageView new];

    self.contentLabel = [GCLabel new];
    [self.contentLabel setUrlJumpBlock:^(NSString *url) {
        NSLog(@"%@",url);
    }];
    
    [self addSubview:self.bubbleImageView];
    [self addSubview:self.contentLabel];
    
    return self;
}

- (void)setLayout:(GCBubbleLayout *)layout {
    _layout = layout;
    
    self.height = layout.height+21*2;

    UIImage *image;
    CGFloat bubbleX;
    if (layout.textLayout.isSelf) {
        image = [UIImage imageNamed:@"GCbubble_right"];
        bubbleX = CGRectGetMinX(layout.textLayout.textLabelFrame) - GCCellContentLayoutMargin/2;

    } else {
        image = [UIImage imageNamed:@"GCbubble_left"];
        bubbleX = CGRectGetMinX(layout.textLayout.textLabelFrame) - GCCellContentLayoutMargin/2 - kGCBubbleArrowWidth;
    }
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 10, 20)
                                  resizingMode:UIImageResizingModeStretch];
    [self.bubbleImageView setFrame:CGRectMake(bubbleX,
                                              kGCAvatarMarginY, layout.width + GCCellContentLayoutMargin, layout.height + GCCellContentLayoutMargin)];
    [self.bubbleImageView setImage:image];
    
    [self.contentLabel setTextLayout:layout.textLayout];
}

@end

@interface GCTextCell ()

@property (nonatomic, strong) GCLabel *label;
@property (nonatomic, strong) GCTextCustomContentView *customContentView;

@end

@implementation GCTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.customContentView  = [GCTextCustomContentView new];
    self.customContentView.cell = self;
    self.customContentView.contentLabel.cell = self;
    
    [self.contentView addSubview:self.customContentView];
    return self;
}

- (void)setLayout:(GCBubbleLayout *)layout {
    self.height = layout.height+21*2;
    self.contentView.height = layout.height+21*2;
    self.customContentView.layout = layout;
}

@end
