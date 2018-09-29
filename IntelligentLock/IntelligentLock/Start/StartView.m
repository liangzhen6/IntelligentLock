//
//  StartView.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/9/28.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "StartView.h"

@interface StartView ()
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UILabel *welcomeTitle;
@end
static StartView * _startView = nil;
@implementation StartView
+ (id)shareStartView {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_startView == nil) {
            _startView = [StartView startView];
        }
    });
    return _startView;
}

+ (id)startView {
    NSString * className = NSStringFromClass([self class]);
    UINib * nib = [UINib nibWithNibName:className bundle:nil];
    StartView * start = [nib instantiateWithOwner:nil options:nil].firstObject;
//    [start initAnimation];
    start.frame = Screen_Frame;
    return start;
}

- (void)initAnimation {
    CABasicAnimation * rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotation.fromValue = [NSNumber numberWithFloat:0.0];
    rotation.toValue = [NSNumber numberWithFloat:M_PI*2];
    rotation.duration = 5.0;
    rotation.repeatCount = MAXFLOAT;
    [_startBtn.layer addAnimation:rotation forKey:@"rotation"];

    [self pauseLayer:_startBtn.layer];
}
// 暂停layer上面的动画
- (void)pauseLayer:(CALayer*)layer {
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

//继续layer上面的动画
-(void)resumeLayer:(CALayer*)layer {
    CFTimeInterval pausedTime = layer.timeOffset;
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval continueTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    // 暂停到恢复之间的空档
    CFTimeInterval timePause = continueTime - pausedTime;
    layer.beginTime = timePause;
}

- (void)setStartRevolve:(BOOL)revolve {
    if (revolve) {
//        _welcomeTitle.text = @"欢迎回来~";
        [self initAnimation];
        [self resumeLayer:_startBtn.layer];
        //设置按钮 交互失效
        self.startBtn.userInteractionEnabled = NO;
//        // 旋转的时候隐藏 welcomeTitle
//        [UIView animateWithDuration:1.0 animations:^{
//            self.welcomeTitle.alpha = 0.0;
//        }];
    } else {
        _welcomeTitle.text = @"欢迎回来~";
        [self pauseLayer:_startBtn.layer];
        // 暂停的时候展示 welcomeTitle
        [UIView animateWithDuration:1.0 animations:^{
            self.welcomeTitle.alpha = 1.0;
        }];
    }
}
// 设置提示语句
- (void)alertTitle:(NSString *)title {
    _welcomeTitle.text = title;
    // 设置呼吸灯效果 opacity
    CABasicAnimation * opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacity.fromValue = [NSNumber numberWithFloat:0.0];
    opacity.toValue = [NSNumber numberWithFloat:1.0];
    opacity.duration = 1.5;
    // 执行可逆动画
    opacity.autoreverses = YES;
    // 设置永远执行动画
    opacity.repeatCount = MAXFLOAT;
    [_welcomeTitle.layer addAnimation:opacity forKey:@"opacity"];

}

- (IBAction)startBtnAction:(UIButton *)sender {
    // 点击 按钮的事件
    //1.先停掉动画
    [_welcomeTitle.layer removeAllAnimations];
    //2. block 通知其他页面处理
    if (self.startBtnBlock) {
        self.startBtnBlock(StartBtnActionTypeTap);
    }
    
}
- (IBAction)btnLongPressAction:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [_welcomeTitle.layer removeAllAnimations];
        // 开始的时候执行，防止多次触发
        if (self.startBtnBlock) {
            self.startBtnBlock(StartBtnActionTypeLongPress);
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
