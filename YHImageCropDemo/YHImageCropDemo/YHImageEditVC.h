//
//  YHImageEditVC.h
//  YHImageCropDemo
//
//  Created by 张长弓 on 2018/1/18.
//  Copyright © 2018年 张长弓. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YHImageEditVC;

@protocol YHDPhotoEditVCDelegate <NSObject>

@optional

- (void)yhdOptionalPhotoEditVC:(YHImageEditVC *)controller didFinishCroppingImage:(UIImage *)croppedImage;

@end

@interface YHImageEditVC : UIViewController

- (instancetype)initWithImage:(UIImage *)aImage delegate:(id<YHDPhotoEditVCDelegate>)aDelegate;

@end
