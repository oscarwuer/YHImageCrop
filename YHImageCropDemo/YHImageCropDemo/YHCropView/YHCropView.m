//
//  YHCropView.m
//  YHImageCropDemo
//
//  Created by 张长弓 on 2018/1/18.
//  Copyright © 2018年 张长弓. All rights reserved.
//

#import "YHCropView.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "YHCropRectView.h"

static const CGFloat MarginTop = 37.0f;
static const CGFloat MarginLeft = 20.0f;

@interface YHCropView ()
<
UIScrollViewDelegate,
UIGestureRecognizerDelegate,
YHDCropRectViewDelegate
>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *zoomingView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) YHCropRectView *cropRectView;
@property (nonatomic, strong) UIView *topOverlayView;
@property (nonatomic, strong) UIView *leftOverlayView;
@property (nonatomic, strong) UIView *rightOverlayView;
@property (nonatomic, strong) UIView *bottomOverlayView;

@property (nonatomic, assign) CGRect insetRect;
@property (nonatomic, assign) CGRect editingRect;

@property (nonatomic, getter = isResizing) BOOL resizing;

// 用来标志是否移动过
@property (nonatomic, assign) BOOL isZoom;

@end

@implementation YHCropView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.delegate = self;
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.maximumZoomScale = 20.0f;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.bounces = NO;
        self.scrollView.bouncesZoom = NO;
        self.scrollView.clipsToBounds = NO;
        [self addSubview:self.scrollView];
        
        self.cropRectView = [[YHCropRectView alloc] init];
        self.cropRectView.delegate = self;
        [self addSubview:self.cropRectView];
        
        self.topOverlayView = [[UIView alloc] init];
        self.topOverlayView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
        [self addSubview:self.topOverlayView];
        
        self.leftOverlayView = [[UIView alloc] init];
        self.leftOverlayView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
        [self addSubview:self.leftOverlayView];
        
        self.rightOverlayView = [[UIView alloc] init];
        self.rightOverlayView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
        [self addSubview:self.rightOverlayView];
        
        self.bottomOverlayView = [[UIView alloc] init];
        self.bottomOverlayView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
        [self addSubview:self.bottomOverlayView];
    }
    
    return self;
}

#pragma mark -

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [self.cropRectView hitTest:[self convertPoint:point toView:self.cropRectView] withEvent:event];
    if (hitView) {
        return hitView;
    }
    CGPoint locationInImageView = [self convertPoint:point toView:self.zoomingView];
    CGPoint zoomedPoint = CGPointMake(locationInImageView.x * self.scrollView.zoomScale, locationInImageView.y * self.scrollView.zoomScale);
    if (CGRectContainsPoint(self.zoomingView.frame, zoomedPoint)) {
        return self.scrollView;
    }
    
    return [super hitTest:point withEvent:event];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.image) {
        return;
    }
    
    self.editingRect = CGRectInset(self.bounds, MarginLeft, MarginTop);
    
    if (!self.imageView) {
        self.insetRect = CGRectInset(self.bounds, MarginLeft, MarginTop);
        [self setupImageView];
    }
    
    if (!self.isResizing) {
        [self layoutCropRectViewWithCropRect:self.scrollView.frame];
    }
}

- (void)layoutCropRectViewWithCropRect:(CGRect)cropRect {
    self.cropRectView.frame = cropRect;
    CGFloat width = cropRect.size.width;
    CGFloat height = cropRect.size.height;
    CGRect rect = CGRectMake(CGRectGetMinX(cropRect),
                             CGRectGetMinY(cropRect) + (height - width)/2,
                             width,
                             width);
    [UIView animateWithDuration:1.0f
                     animations:^{
                         self.cropRectView.frame = rect;
                     } completion:^(BOOL finished) {
                         
                     }];
    [self layoutOverlayViewsWithCropRect:cropRect];
}

- (void)layoutOverlayViewsWithCropRect:(CGRect)cropRect {
    self.topOverlayView.frame = CGRectMake(0.0f,
                                           0.0f,
                                           CGRectGetWidth(self.bounds),
                                           CGRectGetMinY(cropRect));
    self.leftOverlayView.frame = CGRectMake(0.0f,
                                            CGRectGetMinY(cropRect),
                                            CGRectGetMinX(cropRect),
                                            CGRectGetHeight(cropRect));
    self.rightOverlayView.frame = CGRectMake(CGRectGetMaxX(cropRect),
                                             CGRectGetMinY(cropRect),
                                             CGRectGetWidth(self.bounds) - CGRectGetMaxX(cropRect),
                                             CGRectGetHeight(cropRect));
    self.bottomOverlayView.frame = CGRectMake(0.0f,
                                              CGRectGetMaxY(cropRect),
                                              CGRectGetWidth(self.bounds),
                                              CGRectGetHeight(self.bounds) - CGRectGetMaxY(cropRect));
}

- (void)setupImageView {
    CGRect cropRect = AVMakeRectWithAspectRatioInsideRect(self.image.size, self.insetRect);
    
    self.scrollView.frame = cropRect;
    self.scrollView.contentSize = cropRect.size;
    
    self.zoomingView = [[UIView alloc] initWithFrame:self.scrollView.bounds];
    self.zoomingView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.zoomingView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.zoomingView.bounds];
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = self.image;
    [self.zoomingView addSubview:self.imageView];
}

#pragma mark -

- (void)setImage:(UIImage *)image {
    _image = image;
    
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    
    [self.zoomingView removeFromSuperview];
    self.zoomingView = nil;
    
    [self setNeedsLayout];
}

- (void)setAspectRatio:(CGFloat)aspectRatio {
    CGRect cropRect = self.scrollView.frame;
    CGFloat width = CGRectGetWidth(cropRect);
    CGFloat height = CGRectGetHeight(cropRect);
    if (width < height) {
        width = height * aspectRatio;
    } else {
        height = width * aspectRatio;
    }
    cropRect.size = CGSizeMake(width, height);
    [self zoomToCropRect:cropRect];
}

- (CGFloat)aspectRatio {
    CGRect cropRect = self.scrollView.frame;
    CGFloat width = CGRectGetWidth(cropRect);
    CGFloat height = CGRectGetHeight(cropRect);
    return width / height;
}

- (void)setCropRect:(CGRect)cropRect {
    [self zoomToCropRect:cropRect];
}

- (CGRect)cropRect {
    return self.scrollView.frame;
}

- (UIImage *)croppedImage {
    // 发送开始裁剪代理
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(yhdOptionalDidBeginingTailor:)]) {
        [self.delegate yhdOptionalDidBeginingTailor:self];
    }
    
    CGRect cropRect = [self convertRect:self.scrollView.frame toView:self.zoomingView];
    CGSize size = self.image.size;
    
    if (!self.isZoom) {
        cropRect = CGRectMake(cropRect.origin.x, cropRect.origin.y, cropRect.size.width, cropRect.size.width);
    }
    
    CGFloat ratio = 1.0f;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || UIInterfaceOrientationIsPortrait(orientation)) {
        ratio = CGRectGetWidth(AVMakeRectWithAspectRatioInsideRect(self.image.size, self.insetRect)) / size.width;
    } else {
        ratio = CGRectGetHeight(AVMakeRectWithAspectRatioInsideRect(self.image.size, self.insetRect)) / size.height;
    }
    
    CGRect zoomedCropRect = CGRectMake(cropRect.origin.x / ratio,
                                       cropRect.origin.y / ratio,
                                       cropRect.size.width / ratio,
                                       cropRect.size.height / ratio);
    
    UIImage *rotatedImage = [self rotatedImageWithImage:self.image transform:self.imageView.transform];
    
    CGImageRef croppedImage = CGImageCreateWithImageInRect(rotatedImage.CGImage, zoomedCropRect);
    UIImage *image = [UIImage imageWithCGImage:croppedImage scale:1.0f orientation:rotatedImage.imageOrientation];
    CGImageRelease(croppedImage);
    
    // 发送结束裁剪代理
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(yhdOptionalDidFinishTailor:)]) {
        [self.delegate yhdOptionalDidFinishTailor:self];
    }
    
    return image;
}

- (UIImage *)rotatedImageWithImage:(UIImage *)image transform:(CGAffineTransform)transform {
    CGSize size = image.size;
    
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, size.width / 2, size.height / 2);
    CGContextConcatCTM(context, transform);
    CGContextTranslateCTM(context, size.width / -2, size.height / -2);
    [image drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
    UIImage *rotatedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return rotatedImage;
}

- (CGRect)cappedCropRectInImageRectWithCropRectView:(YHCropRectView *)cropRectView {
    CGRect cropRect = cropRectView.frame;
    
    CGRect rect = [self convertRect:cropRect toView:self.scrollView];
    if (CGRectGetMinX(rect) < CGRectGetMinX(self.zoomingView.frame)) {
        cropRect.origin.x = CGRectGetMinX([self.scrollView convertRect:self.zoomingView.frame toView:self]);
        cropRect.size.width = CGRectGetMaxX(rect);
    }
    if (CGRectGetMinY(rect) < CGRectGetMinY(self.zoomingView.frame)) {
        cropRect.origin.y = CGRectGetMinY([self.scrollView convertRect:self.zoomingView.frame toView:self]);
        cropRect.size.height = CGRectGetMaxY(rect);
    }
    if (CGRectGetMaxX(rect) > CGRectGetMaxX(self.zoomingView.frame)) {
        cropRect.size.width = CGRectGetMaxX([self.scrollView convertRect:self.zoomingView.frame toView:self]) - CGRectGetMinX(cropRect);
    }
    if (CGRectGetMaxY(rect) > CGRectGetMaxY(self.zoomingView.frame)) {
        cropRect.size.height = CGRectGetMaxY([self.scrollView convertRect:self.zoomingView.frame toView:self]) - CGRectGetMinY(cropRect);
    }
    
    return cropRect;
}

- (void)automaticZoomIfEdgeTouched:(CGRect)cropRect {
    if (CGRectGetMinX(cropRect) < CGRectGetMinX(self.editingRect) - 5.0f ||
        CGRectGetMaxX(cropRect) > CGRectGetMaxX(self.editingRect) + 5.0f ||
        CGRectGetMinY(cropRect) < CGRectGetMinY(self.editingRect) - 5.0f ||
        CGRectGetMaxY(cropRect) > CGRectGetMaxY(self.editingRect) + 5.0f) {
        [UIView animateWithDuration:1.0
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self zoomToCropRect:self.cropRectView.frame];
                         } completion:^(BOOL finished) {
                             
                         }];
    }
}

#pragma mark -

- (void)yhOptionalCropRectViewDidBeginEditing:(YHCropRectView *)cropRectView {
    self.resizing = YES;
    self.isZoom = YES;
}

- (void)yhOptionalCropRectViewEditingChanged:(YHCropRectView *)cropRectView {
    CGRect cropRect = [self cappedCropRectInImageRectWithCropRectView:cropRectView];
    
    [self layoutCropRectViewWithCropRect:cropRect];
    
    [self automaticZoomIfEdgeTouched:cropRect];
}

- (void)yhOptionalCropRectViewDidEndEditing:(YHCropRectView *)cropRectView {
    self.resizing = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.resizing) {
            [self zoomToCropRect:self.cropRectView.frame];
        }
    });
}

- (void)zoomToCropRect:(CGRect)toRect {
    if (CGRectEqualToRect(self.scrollView.frame, toRect)) {
        return;
    }
    
    CGFloat width = CGRectGetWidth(toRect);
    CGFloat height = CGRectGetHeight(toRect);
    
    CGFloat scale = MIN(CGRectGetWidth(self.editingRect) / width, CGRectGetHeight(self.editingRect) / height);
    
    CGFloat scaledWidth = width * scale;
    CGFloat scaledHeight = height * scale;
    CGRect cropRect = CGRectMake((CGRectGetWidth(self.bounds) - scaledWidth) / 2,
                                 (CGRectGetHeight(self.bounds) - scaledHeight) / 2,
                                 scaledWidth,
                                 scaledHeight);
    
    CGRect zoomRect = [self convertRect:toRect toView:self.zoomingView];
    zoomRect.size.width = CGRectGetWidth(cropRect) / (self.scrollView.zoomScale * scale);
    zoomRect.size.height = CGRectGetHeight(cropRect) / (self.scrollView.zoomScale * scale);
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.scrollView.bounds = cropRect;
                         [self.scrollView zoomToRect:zoomRect animated:NO];
                         
                         [self layoutCropRectViewWithCropRect:cropRect];
                     } completion:^(BOOL finished) {
                         
                     }];
}

#pragma mark -

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.zoomingView;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGPoint contentOffset = scrollView.contentOffset;
    *targetContentOffset = contentOffset;
}

@end
