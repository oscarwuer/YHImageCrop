//
//  YHCropRectView.m
//  YHImageCropDemo
//
//  Created by 张长弓 on 2018/1/18.
//  Copyright © 2018年 张长弓. All rights reserved.
//

#import "YHCropRectView.h"
#import "YHResizeView.h"

@interface YHCropRectView () <YHDResizeConrolViewDelegate>

@property (nonatomic, strong) YHResizeView *topLeftCornerView;
@property (nonatomic, strong) YHResizeView *topRightCornerView;
@property (nonatomic, strong) YHResizeView *bottomLeftCornerView;
@property (nonatomic, strong) YHResizeView *bottomRightCornerView;
@property (nonatomic, strong) YHResizeView *topEdgeView;
@property (nonatomic, strong) YHResizeView *leftEdgeView;
@property (nonatomic, strong) YHResizeView *bottomEdgeView;
@property (nonatomic, strong) YHResizeView *rightEdgeView;

@property (nonatomic, assign) CGRect initialRect;
@property (nonatomic, getter = isLiveResizing) BOOL liveResizing;

@property (nonatomic, assign) CGRect firstRecordRect;
@property (nonatomic, assign) BOOL isRecord;

@end

@implementation YHCropRectView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeRedraw;
        
        self.showsGridMajor = YES;
        self.showsGridMinor = NO;
        
        self.isRecord = NO;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, -2.0f, -2.0f)];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.image = [[UIImage imageNamed:@"photoCropEditorBorder"] resizableImageWithCapInsets:UIEdgeInsetsMake(23.0f, 23.0f, 23.0f, 23.0f)];
        [self addSubview:imageView];
        
        self.topLeftCornerView = [[YHResizeView alloc] init];
        self.topLeftCornerView.delegate = self;
        [self addSubview:self.topLeftCornerView];
        
        self.topRightCornerView = [[YHResizeView alloc] init];
        self.topRightCornerView.delegate = self;
        [self addSubview:self.topRightCornerView];
        
        self.bottomLeftCornerView = [[YHResizeView alloc] init];
        self.bottomLeftCornerView.delegate = self;
        [self addSubview:self.bottomLeftCornerView];
        
        self.bottomRightCornerView = [[YHResizeView alloc] init];
        self.bottomRightCornerView.delegate = self;
        [self addSubview:self.bottomRightCornerView];
        
        self.topEdgeView = [[YHResizeView alloc] init];
        self.topEdgeView.delegate = self;
        [self addSubview:self.topEdgeView];
        
        self.leftEdgeView = [[YHResizeView alloc] init];
        self.leftEdgeView.delegate = self;
        [self addSubview:self.leftEdgeView];
        
        self.bottomEdgeView = [[YHResizeView alloc] init];
        self.bottomEdgeView.delegate = self;
        [self addSubview:self.bottomEdgeView];
        
        self.rightEdgeView = [[YHResizeView alloc] init];
        self.rightEdgeView.delegate = self;
        [self addSubview:self.rightEdgeView];
    }
    return self;
}

#pragma mark -

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    NSArray *subviews = self.subviews;
    for (UIView *subview in subviews) {
        if ([subview isKindOfClass:[YHResizeView class]]) {
            if (CGRectContainsPoint(subview.frame, point)) {
                return subview;
            }
        }
    }
    
    return nil;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    for (NSInteger i = 0; i < 3; i++) {
        if (self.showsGridMinor) {
            for (NSInteger j = 1; j < 3; j++) {
                [[UIColor colorWithRed:1.0f green:1.0f blue:0.0f alpha:0.3f] set];
                
                UIRectFill(CGRectMake(roundf(width / 3 / 3 * j + width / 3 * i), 0.0f, 1.0f, roundf(height)));
                UIRectFill(CGRectMake(0.0f, roundf(height / 3 / 3 * j + height / 3 * i), roundf(width), 1.0f));
            }
        }
        
        if (self.showsGridMajor) {
            if (i > 0) {
                [[UIColor whiteColor] set];
                
                UIRectFill(CGRectMake(roundf(width / 3 * i), 0.0f, 1.0f, roundf(height)));
                UIRectFill(CGRectMake(0.0f, roundf(height / 3 * i), roundf(width), 1.0f));
            }
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.topLeftCornerView.frame = (CGRect){CGRectGetWidth(self.topLeftCornerView.bounds) / -2, CGRectGetHeight(self.topLeftCornerView.bounds) / -2, self.topLeftCornerView.bounds.size};
    self.topRightCornerView.frame = (CGRect){CGRectGetWidth(self.bounds) - CGRectGetWidth(self.topRightCornerView.bounds) / 2, CGRectGetHeight(self.topRightCornerView.bounds) / -2, self.topLeftCornerView.bounds.size};
    self.bottomLeftCornerView.frame = (CGRect){CGRectGetWidth(self.bottomLeftCornerView.bounds) / -2, CGRectGetHeight(self.bounds) - CGRectGetHeight(self.bottomLeftCornerView.bounds) / 2, self.bottomLeftCornerView.bounds.size};
    self.bottomRightCornerView.frame = (CGRect){CGRectGetWidth(self.bounds) - CGRectGetWidth(self.bottomRightCornerView.bounds) / 2, CGRectGetHeight(self.bounds) - CGRectGetHeight(self.bottomRightCornerView.bounds) / 2, self.bottomRightCornerView.bounds.size};
    self.topEdgeView.frame = (CGRect){CGRectGetMaxX(self.topLeftCornerView.frame), CGRectGetHeight(self.topEdgeView.frame) / -2, CGRectGetMinX(self.topRightCornerView.frame) - CGRectGetMaxX(self.topLeftCornerView.frame), CGRectGetHeight(self.topEdgeView.bounds)};
    self.leftEdgeView.frame = (CGRect){CGRectGetWidth(self.leftEdgeView.frame) / -2, CGRectGetMaxY(self.topLeftCornerView.frame), CGRectGetWidth(self.leftEdgeView.bounds), CGRectGetMinY(self.bottomLeftCornerView.frame) - CGRectGetMaxY(self.topLeftCornerView.frame)};
    self.bottomEdgeView.frame = (CGRect){CGRectGetMaxX(self.bottomLeftCornerView.frame), CGRectGetMinY(self.bottomLeftCornerView.frame), CGRectGetMinX(self.bottomRightCornerView.frame) - CGRectGetMaxX(self.bottomLeftCornerView.frame), CGRectGetHeight(self.bottomEdgeView.bounds)};
    self.rightEdgeView.frame = (CGRect){CGRectGetWidth(self.bounds) - CGRectGetWidth(self.rightEdgeView.bounds) / 2, CGRectGetMaxY(self.topRightCornerView.frame), CGRectGetWidth(self.rightEdgeView.bounds), CGRectGetMinY(self.bottomRightCornerView.frame) - CGRectGetMaxY(self.topRightCornerView.frame)};
}

#pragma mark -

- (void)setShowsGridMajor:(BOOL)showsGridMajor
{
    _showsGridMajor = showsGridMajor;
    [self setNeedsDisplay];
}

- (void)setShowsGridMinor:(BOOL)showsGridMinor
{
    _showsGridMinor = showsGridMinor;
    [self setNeedsDisplay];
}

#pragma mark -

- (void)yhdOptionalResizeConrolViewDidBeginResizing:(YHResizeView *)resizeConrolView
{
    self.liveResizing = YES;
    self.initialRect = self.frame;
    
    if ([self.delegate respondsToSelector:@selector(yhOptionalCropRectViewDidBeginEditing:)]) {
        [self.delegate yhOptionalCropRectViewDidBeginEditing:self];
    }
    
    
    if (!self.isRecord && CGRectGetWidth(self.initialRect) > 0) {
        self.isRecord = YES;
        self.firstRecordRect = self.initialRect;
    }
}

- (void)yhdOptionalResizeConrolViewDidResize:(YHResizeView *)resizeConrolView
{
    self.frame = [self cropRectMakeWithResizeControlView:resizeConrolView];
    
    if ([self.delegate respondsToSelector:@selector(yhOptionalCropRectViewEditingChanged:)]) {
        [self.delegate yhOptionalCropRectViewEditingChanged:self];
    }
}

- (void)yhdOptionalResizeConrolViewDidEndResizing:(YHResizeView *)resizeConrolView
{
    self.liveResizing = NO;
    
    if ([self.delegate respondsToSelector:@selector(yhOptionalCropRectViewDidEndEditing:)]) {
        [self.delegate yhOptionalCropRectViewDidEndEditing:self];
    }
}

- (CGRect)cropRectMakeWithResizeControlView:(YHResizeView *)resizeControlView
{
    CGRect rect = self.frame;
    
    if (resizeControlView == self.topEdgeView) {
        CGFloat width = CGRectGetHeight(self.initialRect) - resizeControlView.translation.y;
        
        rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.y/2,
                          CGRectGetMinY(self.initialRect) + resizeControlView.translation.y,
                          width,
                          width);
    } else if (resizeControlView == self.leftEdgeView) {
        CGFloat width = CGRectGetWidth(self.initialRect) - resizeControlView.translation.x;
        
        rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetMinY(self.initialRect) + resizeControlView.translation.x/2,
                          width,
                          width);
    } else if (resizeControlView == self.bottomEdgeView) {
        CGFloat width = CGRectGetHeight(self.initialRect) + resizeControlView.translation.y;
        
        rect = CGRectMake(CGRectGetMinX(self.initialRect) - resizeControlView.translation.y/2,
                          CGRectGetMinY(self.initialRect),
                          width,
                          width);
    } else if (resizeControlView == self.rightEdgeView) {
        CGFloat width = CGRectGetWidth(self.initialRect) + resizeControlView.translation.x;
        
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect) - resizeControlView.translation.x/2,
                          width,
                          width);
    } else if (resizeControlView == self.topLeftCornerView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetMinY(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetWidth(self.initialRect) - resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect) - resizeControlView.translation.x);
    } else if (resizeControlView == self.topRightCornerView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect) + resizeControlView.translation.y,
                          CGRectGetWidth(self.initialRect) - resizeControlView.translation.y,
                          CGRectGetHeight(self.initialRect) - resizeControlView.translation.y);
    } else if (resizeControlView == self.bottomLeftCornerView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect) - resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect) - resizeControlView.translation.x);
    } else if (resizeControlView == self.bottomRightCornerView) {
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect) + resizeControlView.translation.x,
                          CGRectGetHeight(self.initialRect) + resizeControlView.translation.x);
    }
    
    CGFloat minWidth = CGRectGetWidth(self.leftEdgeView.bounds) + CGRectGetWidth(self.rightEdgeView.bounds);
    if (CGRectGetWidth(rect) < minWidth) {
        rect.origin.x = CGRectGetMaxX(self.frame) - minWidth;
        rect.size.width = minWidth;
    }
    
    CGFloat minHeight = CGRectGetHeight(self.topEdgeView.bounds) + CGRectGetHeight(self.bottomEdgeView.bounds);
    if (CGRectGetHeight(rect) < minHeight) {
        rect.origin.y = CGRectGetMaxY(self.frame) - minHeight;
        rect.size.height = minHeight;
    }
    
    // 边界之外不让滑动
    rect = CGRectMake(MAX(CGRectGetMinX(rect), CGRectGetMinX(self.firstRecordRect)),
                      MAX(CGRectGetMinY(rect), CGRectGetMinY(self.firstRecordRect)),
                      MIN(CGRectGetWidth(rect), CGRectGetWidth(self.firstRecordRect)),
                      MIN(CGRectGetHeight(rect), CGRectGetHeight(self.firstRecordRect)));
    
    return rect;
}

@end
