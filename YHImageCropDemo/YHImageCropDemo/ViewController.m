//
//  ViewController.m
//  YHImageCropDemo
//
//  Created by 张长弓 on 2018/1/18.
//  Copyright © 2018年 张长弓. All rights reserved.
//

#import "ViewController.h"
#import "YHPhotoSelect.h"

@interface ViewController ()
<
YHDPhotoSelectDelegate
>

@property (weak, nonatomic) IBOutlet UIButton *imageShowBtn;

@property (nonatomic, strong) YHPhotoSelect *photoSelect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"头像剪裁Demo";
    
    // 裁剪成圆形头像展示
    self.imageShowBtn.layer.cornerRadius = 120/2;
    self.imageShowBtn.layer.masksToBounds = YES;
    
    // 初始化配置
    self.photoSelect = [[YHPhotoSelect alloc] initWithController:self delegate:self];
    self.photoSelect.isAllowEdit = YES;
}

#pragma mark - Click Events

- (IBAction)btnClickImageSelected:(id)sender {
    // 从相册选择照片
    [self.photoSelect startPhotoSelect:YHEPhotoSelectFromLibrary];
}

#pragma mark - Private Methods

// 裁剪图片
- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect{
    
    //将UIImage转换成CGImageRef
    CGImageRef sourceImageRef = [image CGImage];
    
    //按照给定的矩形区域进行剪裁
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    
    //将CGImageRef转换成UIImage
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    //返回剪裁后的图片
    return newImage;
}

#pragma mark - Delegates

#pragma mark - YHDPhotoSelectDelegate

// 选择完成后的回调
- (void)yhdOptionalPhotoSelect:(YHPhotoSelect *)photoSelect didFinishedWithImageArray:(NSArray *)imageArray {
    UIImage *img = imageArray.lastObject;
    UIImage *resultImg = img;
    
    // 未经过剪裁（isAllowEdit = NO）的情况下，对返回图片做裁剪，以保证 1：1
    if (img.size.width != img.size.height) {
        if (img.size.width > img.size.height) {
            CGFloat left = (img.size.width - img.size.height)/2;
            resultImg = [self imageFromImage:img inRect:CGRectMake(left, 0, img.size.height, img.size.height)];
        } else if (img.size.width < img.size.height) {
            CGFloat top = (img.size.height - img.size.width)/2;
            resultImg = [self imageFromImage:img inRect:CGRectMake(0, top, img.size.width, img.size.width)];
        }
    }
    // 展示出来
    [self.imageShowBtn setBackgroundImage:resultImg forState:UIControlStateNormal];
}

// 照片选择取消后的回调
- (void)yhdOptionalPhotoSelectDidCancelled:(YHPhotoSelect *)photoSelect {
    // dummy
}

@end
