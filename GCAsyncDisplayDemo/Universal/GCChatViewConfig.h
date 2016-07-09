//
//  GCChatViewConfig.h
//  GCMobSDK
//
//  Created by 宫城 on 15/11/26.
//  Copyright © 2015年 宫城. All rights reserved.
//

#ifndef GCChatViewConfig_h
#define GCChatViewConfig_h

/**
 *  avatar config
 */
#define kGCAvatarMarginX 10
#define kGCAvatarMarginY 12
#define kGCAvatarWidth 40
#define kGCAvatarHeight 40

/**
 *  bubble config
 */
#define kGCBubbleMarginX 5
#define kGCBubbleMarginY 5
#define kGCBubbleArrowWidth 10

/**
 *  文本距离气泡边距
 */
static CGFloat GCCellContentLayoutMargin = 18;

/**
 *  alert提醒
 */
#define GC_NO_MICROPHONE_PERMISSION                                                               \
    @"请在iPhone的“设置-隐私-"                                                            \
    @"麦克风”选项中，允许访问你的手机麦克风。"
#define GC_VOICE_LOAD_ERROR @"语音下载失败"
#define GC_EMPTY_LIST_PREFIX_NEW @"按\"+\"添加一个"
#define GC_SERVER_ERROR_MSG @"服务器请求错误"

/**
 *  color config
 */
#define GCUIColorFromRGB(rgbValue)                                                                \
    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0                           \
                    green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0                              \
                     blue:((float)(rgbValue & 0xFF)) / 255.0                                       \
                    alpha:1.0]

#define GCColorGray 0xB4B4B4
#define GCColorRed 0xff5050
#define GCColorTableSeparate 0xe8e9eb
#define GCColorTitle 0x222222
#define GCColorGrayDark 0x6B6B6B
#define GCColorBlue 0x56ABE4
#define GCColorBlueDark 0x165A7F
#define GCColorBlueLight 0x8BCBFF

#define GCNavigationTint 0x505050

/**
 *  other
 */
#define GC_DEVICE_WIDTH [[UIScreen mainScreen] bounds].size.width
#define GC_DEVICE_HEIGHT [[UIScreen mainScreen] bounds].size.height

#endif /* ChatViewConfig_h */
