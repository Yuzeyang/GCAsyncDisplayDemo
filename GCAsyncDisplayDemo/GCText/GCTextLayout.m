//
//  GCTextLayout.m
//  TextLayoutDemo
//
//  Created by 宫城 on 16/6/24.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import "GCTextLayout.h"
#import <CoreText/CoreText.h>
#import "GCChatViewConfig.h"
#import "GCEmojiRegex.h"
#import "GCCellContentRectHelper.h"

/**
 *  文本字体大小
 */
static const CGFloat kGCTextFontSize = 16;

/**
 *  文本原点Y
 */
static const CGFloat kGCTextCellOriginY = 21;

/**
 *  文本显示宽度
 */
static const CGFloat kGCTextCellWidth = 192;

/**
 *  文本显示默认高度
 */
static const CGFloat kGCTextCellHeight = 20;

@interface GCTextLayout ()

@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) BOOL isSelf;
@property (nonatomic, assign) CGRect textLabelFrame;
@property (nonatomic, strong) NSMutableAttributedString *attributedContent;

@property (nonatomic, strong) UIColor *nomalColor;
@property (nonatomic, strong) UIColor *urlColor;
@property (nonatomic, strong) UIColor *touchColor;

@property (nonatomic, strong) NSArray *htmlMatchArray;
@property (nonatomic, assign) NSRange htmlRange;
@property (nonatomic, copy) NSString *htmlUrl;

@property (nonatomic, strong) NSArray *emojiMatchArray;

@property (nonatomic, strong) NSArray *urlMatchArray;
@property (nonatomic, strong) NSMutableArray *urlRangeArray;

@end

@implementation GCTextLayout

@synthesize content,htmlUrl;

#pragma mark - initialize
- (instancetype)initWithContent:(NSString *)originContent isSelf:(BOOL)isSelf {
    self = [super init];
    if (self) {
        self.urlRangeArray = [NSMutableArray array];
        self.content = originContent;
        self.isSelf = isSelf;
        self.nomalColor = isSelf ? [UIColor whiteColor] : GCUIColorFromRGB(GCColorGrayDark);
        self.urlColor = isSelf ? GCUIColorFromRGB(GCColorBlueLight) : GCUIColorFromRGB(GCColorBlue);
        self.touchColor = isSelf ? GCUIColorFromRGB(GCColorGrayDark) : GCUIColorFromRGB(GCColorBlueDark);
        [self handleContent];
    }
    return self;
}

#pragma mark - getter
- (UIFont *)font {
    return [UIFont systemFontOfSize:kGCTextFontSize];
}

#pragma mark - private methods
- (void)handleContent {
    if (!self.content.length) {
        CGFloat resizeWidth = 1;
        CGFloat textLabelOriginX = 0;
//        CGFloat x = kGCAvatarMarginX + kGCAvatarWidth + kGCBubbleMarginX + kGCBubbleArrowWidth + GCTextLayoutMargin/2;
        if (self.isSelf) {
            textLabelOriginX = [GCCellContentRectHelper rightOriginXWithContentWidth:resizeWidth];
        } else {
            textLabelOriginX = [GCCellContentRectHelper leftOriginX];
        }
        self.textLabelFrame = CGRectMake(textLabelOriginX, kGCTextCellOriginY, resizeWidth, kGCTextCellHeight);
    } else {
        NSRegularExpression *emojiRegex =
        [NSRegularExpression regularExpressionWithPattern:kGCEmojiRegex options:0 error:nil];
        NSArray *emojiMatchArray =
        [emojiRegex matchesInString:self.content options:0 range:NSMakeRange(0, self.content.length)];
        self.emojiMatchArray = emojiMatchArray;
        
        NSRegularExpression *urlRegex =
        [NSRegularExpression regularExpressionWithPattern:kGCURLRegex options:0 error:nil];
        NSArray *urlMatchArray =
        [urlRegex matchesInString:self.content options:0 range:NSMakeRange(0, self.content.length)];
        self.urlMatchArray = urlMatchArray;
        
        NSRegularExpression *htmlRegex =
        [NSRegularExpression regularExpressionWithPattern:kGCHtmlRegex options:0 error:nil];
        NSArray *htmlMatchArray =
        [htmlRegex matchesInString:self.content options:0 range:NSMakeRange(0, self.content.length)];
        self.htmlMatchArray = htmlMatchArray;
        
        [self buildAttribute];
        [self caculateFrame];
    }
}

#pragma mark - core text handle
-(void)buildAttribute {
    self.attributedContent = [[NSMutableAttributedString alloc] initWithString:self.content];
    [self.attributedContent addAttribute:(id)kCTForegroundColorAttributeName value:(id)self.nomalColor.CGColor range:NSMakeRange(0, self.attributedContent.length)];
    
    //换行模式，设置段落属性
    CTParagraphStyleSetting lineBreakMode;
    CTLineBreakMode lineBreak = kCTLineBreakByCharWrapping;
    lineBreakMode.spec = kCTParagraphStyleSpecifierMinimumLineSpacing;
    lineBreakMode.value = &lineBreak;
    lineBreakMode.valueSize = sizeof(CTLineBreakMode);
    
    CTParagraphStyleSetting settings[] = {
        lineBreakMode
    };
    CTParagraphStyleRef style = CTParagraphStyleCreate(settings, 1);
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:(__bridge id)style forKey:(id)kCTParagraphStyleAttributeName];
    [self.attributedContent addAttributes:attributes range:NSMakeRange(0, [self.attributedContent length])];
    
    [self buildHtmlAttribute];
    [self buildUrlAttribute];
    [self buildEmojiAttribute];
    
    if (style) {
        CFRelease(style);
    }
    //设置字体
    [self.attributedContent addAttribute:(id)kCTFontAttributeName
                              value:CFBridgingRelease(CTFontCreateWithName((CFStringRef)self.font.fontName, [self.font pointSize], NULL))
                              range:NSMakeRange(0, self.attributedContent.string.length)];
}

-(void)buildHtmlAttribute {
    //html解析
    for (NSTextCheckingResult *htmlResult in self.htmlMatchArray) {
        NSRange range = htmlResult.range;
        NSString *matchString = [self.content substringWithRange:range];
        NSString *htmlContent = [self getHtmlContent:matchString];
        NSRange newRange = [self.attributedContent.string rangeOfString:matchString];
        [self.attributedContent replaceCharactersInRange:newRange withString:htmlContent];
        NSRange htmlInContentRange = [matchString rangeOfString:htmlContent];
        htmlInContentRange.location = newRange.location;
        if (htmlResult == self.htmlMatchArray[0]) {
            self.htmlRange = htmlInContentRange;
            NSString *matchHtmlUrl = [self getHtmlUrl:matchString];
            self.htmlUrl = matchHtmlUrl;
            [self.attributedContent addAttribute:(id)kCTForegroundColorAttributeName value:(id)self.urlColor.CGColor range:htmlInContentRange];
            [self.attributedContent addAttribute:(id)kCTUnderlineStyleAttributeName value:(id)[NSNumber numberWithInt:kCTUnderlineStyleSingle] range:htmlInContentRange];
        }
    }
}

-(void)buildUrlAttribute {
    //url解析
    for (NSTextCheckingResult *urlResult in self.urlMatchArray) {
        NSRange range = urlResult.range;
        if(range.location == NSNotFound) {
            break;
        }
        
        NSString *matchString = [self.content substringWithRange:range];
        NSRange realRange = [self.attributedContent.string rangeOfString:matchString];
        if ([self.urlMatchArray containsObject:[NSValue valueWithRange:realRange]]) {
            if(realRange.location == NSNotFound) {
                break;
            }
            realRange = [self.attributedContent.string rangeOfString:matchString options:NSCaseInsensitiveSearch range:NSMakeRange(realRange.location+realRange.length, self.attributedContent.string.length - realRange.location - realRange.length)];
        }
        BOOL isInHTML = NO;
        for (NSTextCheckingResult *htmlResult in self.htmlMatchArray) {
            NSRange fakeRange = htmlResult.range;
            if (NSLocationInRange(range.location, fakeRange) && NSLocationInRange(range.location+range.length, fakeRange)) {
                isInHTML = YES;
                break;
            }
        }
        //去除包含在HTML标签中的URL
        if (!isInHTML) {
            [self.urlRangeArray addObject:[NSValue valueWithRange:realRange]];
            [self.attributedContent addAttribute:(id)kCTForegroundColorAttributeName value:(id)self.urlColor.CGColor range:realRange];
            [self.attributedContent addAttribute:(id)kCTUnderlineStyleAttributeName value:(id)[NSNumber numberWithInt:kCTUnderlineStyleSingle] range:realRange];
        }
    }
}

-(void)buildEmojiAttribute {
    //创建图片的名字
    NSString *emptyString = @"\u205f";
    for (NSTextCheckingResult *matchResult in self.emojiMatchArray) {
        NSRange range = matchResult.range;
        NSString *matchString = [self.content substringWithRange:range];
        NSString *imageName = [NSString stringWithFormat:@"GC%@.png",kGCEmojiMatchDic[matchString]];
        //设置CTRun的回调，用于针对需要被替换成图片的位置的字符，可以动态设置图片预留位置的宽高
        CTRunDelegateCallbacks imageCallbacks;
        imageCallbacks.version = kCTRunDelegateVersion1;
        imageCallbacks.dealloc = RunDelegateDeallocCallback;
        imageCallbacks.getAscent = RunDelegateGetAscentCallback;
        imageCallbacks.getDescent = RunDelegateGetDescentCallback;
        imageCallbacks.getWidth = RunDelegateGetWidthCallback;
        //创建CTRun回调
        CTRunDelegateRef runDelegate = CTRunDelegateCreate(&imageCallbacks, (__bridge void *)(imageName));
        //这里为了简化解析文字，所以直接认为最后一个字符是需要显示图片的位置，对需要显示图片的位置，都用空字符来替换原来的字符，空格用于给图片留位置
        NSMutableAttributedString *imageAttributedString = [[NSMutableAttributedString alloc] initWithString:emptyString];
        //设置图片预留字符使用CTRun回调
        [imageAttributedString addAttribute:(NSString *)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:NSMakeRange(0, emptyString.length)];
        CFRelease(runDelegate);
        //设置图片预留字符使用一个imageName的属性，区别于其他字符
        [imageAttributedString addAttribute:@"imageName" value:imageName range:NSMakeRange(0, emptyString.length)];
        NSRange newRange = [self.attributedContent.string rangeOfString:matchString];
        [self.attributedContent replaceCharactersInRange:newRange withAttributedString:imageAttributedString];
    }
}

#pragma mark - html标签解析
-(NSString *)getHtmlContent:(NSString *)html {
    NSRange startRange = [html rangeOfString:@">"];
    NSRange endRange = [html rangeOfString:@"</a>"];
    if (startRange.location == NSNotFound || endRange.location == NSNotFound) {
        return @"";
    } else {
        NSString *htmlContent = [html substringWithRange:NSMakeRange(startRange.location+1,endRange.location-startRange.location-1)];
        return htmlContent;
    }
}

-(NSString *)getHtmlUrl:(NSString *)html{
    NSRange startRange = [html rangeOfString:@"=\""];
    NSRange endRange = [html rangeOfString:@"\">"];
    if (startRange.location == NSNotFound || endRange.location == NSNotFound) {
        return @"";
    }else{
        NSString *matchHtmlUrl = [html substringWithRange:NSMakeRange(startRange.location+1+1,endRange.location-1-startRange.location-1)];
        return matchHtmlUrl;
    }
}

#pragma mark - caculate text label height and width
- (void)caculateFrame {
    CGFloat textLabelHeight = [self getContentHeight];
    CGFloat textLabelWidth = [self getContentWidth];

//    CGFloat x = kGCAvatarMarginX + kGCAvatarWidth + kGCBubbleMarginX + kGCBubbleArrowWidth + GCTextLayoutMargin/2;
    CGFloat textLabelOriginX = self.isSelf ?
    [GCCellContentRectHelper rightOriginXWithContentWidth:textLabelWidth] : [GCCellContentRectHelper leftOriginX];
    self.textLabelFrame = CGRectMake(textLabelOriginX, kGCTextCellOriginY, textLabelWidth, textLabelHeight);
}

- (CGFloat)getContentHeight {
    int total_height = 0;
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedContent);
    CGRect drawingRect = CGRectMake(0, 0, kGCTextCellWidth, 1000000);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, drawingRect);
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CGPathRelease(path);
    CFRelease(framesetter);
    
    NSArray *linesArray = (NSArray *)CTFrameGetLines(textFrame);
    
    CGPoint origins[[linesArray count]];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
    
    int line_y = (int)origins[[linesArray count] - 1].y;  //最后一行line的原点y坐标
    
    CGFloat ascent;
    CGFloat descent;
    CGFloat leading;
    
    CTLineRef line = (__bridge CTLineRef)[linesArray objectAtIndex:[linesArray count] - 1];
    CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    
    total_height = 1000000 - line_y + (int)descent + 1;  //+1为了纠正descent转换成int小数点后舍去的值
    
    CFRelease(textFrame);
    if (total_height < kGCTextCellHeight) {
        total_height = kGCTextCellHeight;
    }
    return total_height;
}

- (CGFloat)getContentWidth {
    CGFloat maxLineWidth = 0.;
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedContent);
    CGRect drawingRect = CGRectMake(0, 0, kGCTextCellWidth, 1000000);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, drawingRect);
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CGPathRelease(path);
    CFRelease(framesetter);
    //获取画出来的内容的行数
    CFArrayRef lines = CTFrameGetLines(textFrame);
    if (CFArrayGetCount(lines) == 1) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, 0);
        //获取每个CTRun
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        
        CGFloat lineWidth = 0.;
        
        for (int j = 0; j < CFArrayGetCount(runs); j++) {
            CGFloat runAscent;
            CGFloat runDescent;
            //获取每个CTRun
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            CGRect runRect;
            //调整CTRun的rect
            runRect.size.width =
            CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, NULL);
            
            lineWidth += runRect.size.width;
        }
        maxLineWidth = lineWidth;
        if (maxLineWidth > kGCTextCellWidth) {
            maxLineWidth = kGCTextCellWidth;
        }
    } else {
        maxLineWidth = kGCTextCellWidth;
    }
    if (textFrame) {
        CFRelease(textFrame);
    }
    return maxLineWidth;
}

#pragma mark run delegate
//CTRun的回调，销毁内存的回调
void RunDelegateDeallocCallback( void* refCon ){
    
}

//CTRun的回调，获取高度
CGFloat RunDelegateGetAscentCallback( void *refCon ){
    return 1;
}

CGFloat RunDelegateGetDescentCallback(void *refCon){
    return 0;
}

//CTRun的回调，获取宽度
CGFloat RunDelegateGetWidthCallback(void *refCon){
    return 18;
}

#pragma mark - NSCoping
- (id)copyWithZone:(NSZone *)zone {
    GCTextLayout *layout = [[self class] allocWithZone:zone];
    layout.content = self.content;
    layout.isSelf = self.isSelf;
    layout.attributedContent = [self.attributedContent mutableCopy];
    layout.textLabelFrame = self.textLabelFrame;
    layout.htmlRange = self.htmlRange;
    layout.htmlUrl = self.htmlUrl;
    layout.touchColor = self.touchColor;
    layout.urlRangeArray = [self.urlRangeArray copy];
    layout.urlColor = self.urlColor;
    return layout;
}

@end
