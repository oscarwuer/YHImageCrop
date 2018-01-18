# YHImageCrop
类似于微信头像编辑

### 效果图
![](http://7xp0ch.com1.z0.glb.clouddn.com/20180118173011.gif)

### 特点
轻量，低耦合，易于集成

### Useage
```
// 初始化配置
self.photoSelect = [[YHPhotoSelect alloc] initWithController:self delegate:self];
self.photoSelect.isAllowEdit = YES;

- (IBAction)btnClickImageSelected:(id)sender {
    // 从相册选择照片
    [self.photoSelect startPhotoSelect:YHEPhotoSelectFromLibrary];
}

```

### 注意
1. isAllowEdit属性默认关闭
2. 目前是拖拽之后1s才确定图片裁剪，1s内随时可以重新更改，这是产品需求，大家可以根据自己的需求重新定义
3. 编辑VC关闭了手势返回
4. iOS 11模拟器可以登录iTunes，大家用模拟器的时候可以用这个方法同步自己的照片
5. Demo中采用的是从相册中选取（YHEPhotoSelectFromLibrary），如果换成拍照，可以换成另一个枚举值（YHEPhotoSelectTakePhoto）

### 待实现
* 多选功能暂未实现
* 当图片过窄时的动画处理，目前动画上稍有欠缺