//
//  StartView.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/9/28.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "StartView.h"
#import "StartAnimationManger.h"

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
    [start initAnimation];
    start.frame = Screen_Frame;
    return start;
}

- (void)initAnimation {
    _welcomeTitle.text = @"欢迎回来~";
    
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
        [self resumeLayer:_startBtn.layer];
        // 旋转的时候隐藏 welcomeTitle
        [UIView animateWithDuration:1.0 animations:^{
            self.welcomeTitle.alpha = 0.0;
        }];
    } else {
        [self pauseLayer:_startBtn.layer];
        // 暂停的时候展示 welcomeTitle
        [UIView animateWithDuration:1.0 animations:^{
            self.welcomeTitle.alpha = 1.0;
        } completion:^(BOOL finished) {
            [[StartAnimationManger shareStartAnimationManger] startAnimationWithBackMainView:KeyWindow.rootViewController.view startView:_startView];
        }];
    }
}

- (IBAction)startBtnAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self setStartRevolve:sender.selected];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
