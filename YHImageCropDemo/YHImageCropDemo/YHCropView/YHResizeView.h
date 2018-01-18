//
//  YHResizeView.h
//  YHImageCropDemo
//
//  Created by 张长弓 on 2018/1/18.
//  Copyright © 2018年 张长弓. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YHResizeView;

@protocol YHDResizeConrolViewDelegate <NSObject>

@optional

- (void)yhdOptionalResizeConrolViewDidBeginResizing:(YHResizeView *)resizeConrolView;

- (void)yhdOptionalResizeConrolViewDidResize:(YHResizeView *)resizeConrolView;

- (void)yhdOptionalResizeConrolViewDidEndResizing:(YHResizeView *)resizeConrolView;

@end

@interface YHResizeView : UIView

@property (nonatomic, weak) id<YHDResizeConrolViewDelegate> delegate;

@property (nonatomic, assign, readonly) CGPoint translation;

@end
