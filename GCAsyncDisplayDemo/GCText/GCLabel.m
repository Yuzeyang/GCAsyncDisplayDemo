//
//  GCLabel.m
//  TextLayoutDemo
//
//  Created by 宫城 on 16/6/24.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import "GCLabel.h"
#import "GCTextLayout.h"
#import <CoreText/CoreText.h>
#import "GCAsyncLayer.h"
#import "GCTextCell.h"
//#import "GCChatViewConfig.h"

@interface GCLabel ()

@property (nonatomic, strong) GCTextLayout *textLayout;
@property (nonatomic, assign) CTFrameRef ctFrame;

@property (nonatomic, assign) NSRange changingRange;
@property (nonatomic, strong) NSString *willJumpUrl;
@property (nonatomic, assign) BOOL isMoved;

@end

@implementation GCLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.frame = frame;
    }
    
    return self;
}

- (void)setTextLayout:(GCTextLayout *)textLayout {
    _textLayout = [textLayout copy];
//    ((GCAsyncLayer *)self.layer).displaysAsynchronously = NO;
    [self setFrame:textLayout.textLabelFrame];
    [self contentNeedUpdate];
}

- (void)contentNeedUpdate {
    [self.layer setNeedsDisplay];
}

#pragma mark - GCAsyncLayerDelegate
+ (Class)layerClass {
    return GCAsyncLayer.class;
}

- (GCAsyncLayerDisplayTask *)newAsyncDisplayTask {
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:self.textLayout.content];
    
    GCAsyncLayerDisplayTask *displayTask = [GCAsyncLayerDisplayTask new];

    __weak __typeof(&*self)weakSelf = self;
    [displayTask setWillDisplay:^(CALayer * _Nonnull layer) {
        layer.contentsScale = 2;
    }];

    [displayTask setDisplay:^(CGContextRef _Nonnull context, CGSize size, BOOL (^ _Nonnull isCancelled)(void)) {
        if (isCancelled()) {
            return;
        }
        if (!text.length) {
            return;
        }
        [weakSelf drawInContext:context withSize:size];
    }];

    [displayTask setDidDisplay:^(CALayer * _Nonnull layer, BOOL isFinish) {
        
    }];

    return displayTask;
}

#pragma mark - private
- (void)drawInContext:(CGContextRef)context withSize:(CGSize)size {
    //设置context的ctm，用于适应core text的坐标体系
    CGContextSaveGState(context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    //设置CTFramesetter
    CTFramesetterRef framesetter =  CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.textLayout.attributedContent);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
    //创建CTFrame
    CTFrameRef ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
//    if (ctFrame == NULL) {
//        return;
//    }
    //把文字内容绘制出来
    CTFrameDraw(ctFrame, context);
    //获取画出来的内容的行数
    CFArrayRef lines = CTFrameGetLines(ctFrame);
    
    //获取每行的原点坐标
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
    
    for (int i = 0; i < CFArrayGetCount(lines); i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        //获取每行的宽度和高度
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        //获取每个CTRun
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        CGFloat lineWidth = 0.;
        for (int j = 0; j < CFArrayGetCount(runs); j++) {
            CGFloat runAscent;
            CGFloat runDescent;
            CGPoint lineOrigin = lineOrigins[i];
            //获取每个CTRun
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            NSDictionary* attributes = (NSDictionary*)CTRunGetAttributes(run);
            CGRect runRect;
            //调整CTRun的rect
            runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
            lineWidth+=runRect.size.width;
            
            runRect=CGRectMake(lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL), lineOrigin.y , runRect.size.width, runAscent+runDescent);
            //CFRelease(run);
            NSString *imageName = [attributes objectForKey:@"imageName"];
            if (imageName) {
                UIImage *image = [UIImage imageNamed:imageName];
                if (image) {
                    CGRect imageDrawRect;
                    imageDrawRect.size =CGSizeMake(18., 18.);
                    imageDrawRect.origin.x = runRect.origin.x + lineOrigin.x;
                    imageDrawRect.origin.y = lineOrigin.y-lineDescent-2;//+drawRect.origin.y;
                    CGContextDrawImage(context, imageDrawRect, image.CGImage);
                }
            }
        }
    }
    CGContextRestoreGState(context);
    CFRelease(framesetter);
    if (path) {
        CGPathRelease(path);
    }
    if (ctFrame) {
        self.ctFrame = CFRetain(ctFrame);
        CFRelease(ctFrame);
    }
}

- (CFIndex)getIndexFromTouch:(UITouch *)touch {
    //获取触摸点击当前view的坐标位置
    CGPoint location = [touch locationInView:self];
    //获取每一行
    CFArrayRef lines = CTFrameGetLines(self.ctFrame);
    CGPoint origins[CFArrayGetCount(lines)];
    //获取每行的原点坐标
    CTFrameGetLineOrigins(self.ctFrame, CFRangeMake(0, 0), origins);
    CTLineRef line = NULL;
    CGPoint lineOrigin = CGPointZero;
    CGPathRef path = CTFrameGetPath(self.ctFrame);
    //获取整个CTFrame的大小
    CGRect rect = CGPathGetBoundingBox(path);
    for (int i = 0; i < CFArrayGetCount(lines); i++) {
        CGPoint origin = origins[i];
        //判断点击的位置处于那一行范围内
        CTLineRef indexLine = CFArrayGetValueAtIndex(lines, i);
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        //获取每行的宽度和高度
        CTLineGetTypographicBounds(indexLine, &lineAscent, &lineDescent, &lineLeading);
        if ((location.y <= rect.size.height - origin.y + 5) && (location.x >= origin.x)) {
            line = CFArrayGetValueAtIndex(lines, i);
            lineOrigin = origin;
            break;
        }
    }
    location.x -= lineOrigin.x;
    //获取点击位置所处的字符位置，就是相当于点击了第几个字符
    CFIndex index = CTLineGetStringIndexForPosition(line, location);
    return index - 1;
}

- (void)verifyColorChangeByIndex:(CFIndex)index {
    if (!NSEqualRanges(self.textLayout.htmlRange, NSMakeRange(0, 0)) && NSLocationInRange(index, self.textLayout.htmlRange)) {
        self.changingRange = self.textLayout.htmlRange;
        self.willJumpUrl = self.textLayout.htmlUrl;
        [self.textLayout.attributedContent addAttribute:(id)kCTForegroundColorAttributeName
                        value:(id)self.textLayout.touchColor.CGColor
                        range:self.textLayout.htmlRange];
        [self.layer setNeedsDisplay];
    } else {
        for (NSValue *rangeValue in self.textLayout.urlRangeArray) {
            NSRange range = [rangeValue rangeValue];
            if (range.location + range.length > self.textLayout.attributedContent.string.length) {
                continue;
            }
            NSString *matchString = [self.textLayout.attributedContent.string substringWithRange:range];
            if (NSLocationInRange(index, range)) {
                self.changingRange = range;
                self.willJumpUrl = matchString;
                [self.textLayout.attributedContent addAttribute:(id)kCTForegroundColorAttributeName
                                value:(id)self.textLayout.touchColor.CGColor
                                range:range];
                [self.layer setNeedsDisplay];
                break;
            }
        }
    }
}

- (void)setShowingRangeToNomal {
    [self.textLayout.attributedContent addAttribute:(id)kCTForegroundColorAttributeName
                    value:(id)self.textLayout.urlColor.CGColor
                    range:self.changingRange];
    self.changingRange = NSMakeRange(0, 0);
    [self.layer setNeedsDisplay];
}

#pragma mark - Touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (!self.ctFrame) {
        return;
    }
    //获取点击位置所处的字符位置，就是相当于点击了第几个字符
    CFIndex index = [self getIndexFromTouch:touch];
    [self verifyColorChangeByIndex:index];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    self.isMoved = YES;
    UITouch *touch = [touches anyObject];
    if (!self.ctFrame) {
        return;
    }
    //获取点击位置所处的字符位置，就是相当于点击了第几个字符
    CFIndex index = [self getIndexFromTouch:touch];
    if (self.changingRange.location == 0 && self.changingRange.length == 0) {
        [self verifyColorChangeByIndex:index];
    } else {
        //仍然在变色的范围内
        if (!NSLocationInRange(index, self.changingRange)) {
            [self setShowingRangeToNomal];
            [self verifyColorChangeByIndex:index];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.isMoved = NO;
    if (!NSEqualRanges(self.changingRange, NSMakeRange(0, 0))) {
        [self setShowingRangeToNomal];
        if ([self.willJumpUrl rangeOfString:@"http://"].location == NSNotFound &&
            [self.willJumpUrl rangeOfString:@"https://"].location == NSNotFound) {
            self.willJumpUrl = [NSString stringWithFormat:@"http://%@", self.willJumpUrl];
        }
        if (self.urlJumpBlock) {
            self.urlJumpBlock(self.willJumpUrl);
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.willJumpUrl]];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!NSEqualRanges(self.changingRange, NSMakeRange(0, 0))) {
        [self setShowingRangeToNomal];
        if ([self.willJumpUrl rangeOfString:@"http://"].location == NSNotFound &&
            [self.willJumpUrl rangeOfString:@"https://"].location == NSNotFound) {
            self.willJumpUrl = [NSString stringWithFormat:@"http://%@", self.willJumpUrl];
        }
        if (!self.isMoved) {
            if (self.urlJumpBlock) {
            }
        }
        self.isMoved = NO;
    }
}

@end
