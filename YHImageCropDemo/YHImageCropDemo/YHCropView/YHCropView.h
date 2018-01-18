//
//  YHCropView.h
//  YHImageCropDemo
//
//  Created by 张长弓 on 2018/1/18.
//  Copyright © 2018年 张长弓. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YHCropView;

@protocol YHDCropViewDelegate <NSObject>

@optional

- (void)yhdOptionalDidBeginingTailor:(YHCropView *)cropView;

- (void)yhdOptionalDidFinishTailor:(YHCropView *)cropView;

@end


@interface YHCropView : UIView

@property (nonatomic, weak) id<YHDCropViewDelegate> delegate;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong, readonly) UIImage *croppedImage;
@property (nonatomic, assign) CGFloat aspectRatio;
@property (nonatomic, assign) CGRect cropRect;

@end
