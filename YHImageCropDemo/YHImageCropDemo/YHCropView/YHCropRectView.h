//
//  YHCropRectView.h
//  YHImageCropDemo
//
//  Created by 张长弓 on 2018/1/18.
//  Copyright © 2018年 张长弓. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YHCropRectView;

@protocol YHDCropRectViewDelegate <NSObject>

- (void)yhOptionalCropRectViewDidBeginEditing:(YHCropRectView *)cropRectView;

- (void)yhOptionalCropRectViewEditingChanged:(YHCropRectView *)cropRectView;

- (void)yhOptionalCropRectViewDidEndEditing:(YHCropRectView *)cropRectView;

@end

@interface YHCropRectView : UIView

@property (nonatomic, weak) id<YHDCropRectViewDelegate> delegate;

@property (nonatomic, assign) BOOL showsGridMajor;

@property (nonatomic, assign) BOOL showsGridMinor;

@end
