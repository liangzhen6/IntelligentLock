//
//  MangerViewController.m
//  LeftMenuDemo
//
//  Created by shenzhenshihua on 2018/9/28.
//  Copyright © 2018年 shenzhenshihua. All rights reserved.
//

#import "MangerViewController.h"

@interface MangerViewController ()
@property(nonatomic,strong)UIView *leftVCView;
@property(nonatomic,strong)UIView *mainVCView;
@property(nonatomic,strong)UIView *maskView;
@property(nonatomic,strong)UIView *leftOpenView;

@end
static MangerViewController * _mangerVC = nil;

@implementation MangerViewController
+ (id)shareMangerViewController {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_mangerVC == nil) {
            _mangerVC = [[MangerViewController alloc] init];
        }
    });
    return _mangerVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view.
}

#pragma mark ---manger 相关的处理
- (void)setLeftViewController:(UIViewController *)leftVC mainViewController:(UIViewController *)mainVC {
    self.leftVCView = leftVC.view;
    self.mainVCView = mainVC.view;
    [_mangerVC addChildViewController:leftVC];
    [_mangerVC addChildViewController:mainVC];
    CGRect frame = _leftVCView.frame;
    frame.origin.x = -MaginWidth/2;
    _leftVCView.frame = frame;
    [_mangerVC.view addSubview:_leftVCView];
    [_mangerVC.view addSubview:_mainVCView];
    
    // 设置阴影
    _mainVCView.layer.shadowColor = [UIColor blackColor].CGColor;
    // 阴影透明度
    _mainVCView.layer.shadowOpacity = 0.5;
    // 阴影切圆角
    _mainVCView.layer.shadowRadius = 4.0;
    // 阴影偏移
    _mainVCView.layer.shadowOffset = CGSizeMake(-3, 0);
    
    
    // 增加侧边栏 呼出手势
    UIView * leftOpenView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, Screen_Height)];
    [mainVC.view addSubview:leftOpenView];
    UIPanGestureRecognizer * leftOpenPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(leftOpenPanAtion:)];
    [leftOpenView addGestureRecognizer:leftOpenPan];
    _leftOpenView = leftOpenView;
    
    // 增加遮罩 + 增加手势
    UIPanGestureRecognizer * maskPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    UITapGestureRecognizer * maskTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    UIView * maskView = [[UIView alloc] initWithFrame:Screen_Frame];
    [mainVC.view addSubview:maskView];
    maskView.alpha = 0.0;
    maskView.backgroundColor = [UIColor blackColor];
    [maskView addGestureRecognizer:maskPan];
    [maskView addGestureRecognizer:maskTap];
    self.maskView = maskView;
}

- (void)mainOpenLeftViewHidden:(BOOL)hidden {
    self.leftOpenView.hidden = hidden;
}

#pragma mark --GestureRecognizer
- (void)panAction:(UIPanGestureRecognizer *)pan {
    CGPoint translatedPoint = [pan translationInView:self.maskView];
    CGPoint velocityPoint =  [pan velocityInView:self.maskView];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {// 开始
            // 保证 mask 永远在 最顶层 的view
            [self.mainVCView addSubview:self.maskView];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {// 变化中
            CGFloat maginX = MaginWidth + translatedPoint.x;
            if (maginX >=0 && maginX < MaginWidth) {
                // 处理mainView
                CGRect mainFrame = _mainVCView.frame;
                mainFrame.origin.x = maginX;
                _mainVCView.frame = mainFrame;
                self.maskView.alpha = maginX * LeftViewAlpha / MaginWidth;
                // 处理leftView
                CGRect leftFrame = _leftVCView.frame;
                leftFrame.origin.x = (maginX - MaginWidth)/2;
                _leftVCView.frame = leftFrame;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {// 结束
            if (_mainVCView.frame.origin.x <= MaginWidth/2 || -velocityPoint.x > 800) {
                // 当滑动距离 大于 MaginWidth 的一半 或者速度 往 关闭的方向 大于800时 就关闭
                [self dismissLeftViewAnimate:YES duration:0.3];
            } else {
                [self showLeftViewAnimate:YES duration:0.1];
            }
        }
            break;
        default:
            break;
    }
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    [self dismissLeftViewAnimate:YES duration:0.3];
}

- (void)leftOpenPanAtion:(UIPanGestureRecognizer *)pan {
    CGPoint translatedPoint = [pan translationInView:pan.view];
    CGPoint velocityPoint =  [pan velocityInView:pan.view];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {// 开始
            // 保证 mask 永远在 最顶层 的view
            [self.mainVCView addSubview:self.maskView];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {// 变化中
            CGFloat maginX = translatedPoint.x;
            if (maginX >=0 && maginX < MaginWidth) {
                // 处理mainView
                CGRect mainFrame = _mainVCView.frame;
                mainFrame.origin.x = maginX;
                _mainVCView.frame = mainFrame;
                self.maskView.alpha = (maginX*LeftViewAlpha)/ MaginWidth;
                // 处理leftView
                CGRect leftFrame = _leftVCView.frame;
                leftFrame.origin.x = maginX/2 - MaginWidth/2;
                _leftVCView.frame = leftFrame;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {// 结束
            if (_mainVCView.frame.origin.x >= MaginWidth/2 || velocityPoint.x > 800) {
                // 当滑动距离 大于 MaginWidth 的一半 或者速度 往 打开的方向 大于800时 就打开
                [self showLeftViewAnimate:YES duration:0.3];
            } else {
                [self dismissLeftViewAnimate:YES duration:0.1];
            }
        }
            break;
        default:
            break;
    }
}

- (void)showLeftViewAnimate:(BOOL)animate duration:(NSTimeInterval)duration {
    if (animate) {
        [UIView animateWithDuration:duration animations:^{
            [self showLeftView];
        }];
    } else {
        [self showLeftView];
    }
}

- (void)showLeftView {
    // 处理 mian 问题
    CGRect mainFrame = self.mainVCView.frame;
    mainFrame.origin.x = MaginWidth;
    self.mainVCView.frame = mainFrame;
    self.maskView.alpha = LeftViewAlpha;
    // 处理 left 问题
    CGRect leftFrame = self.leftVCView.frame;
    leftFrame.origin.x = 0;
    self.leftVCView.frame = leftFrame;
}

- (void)dismissLeftViewAnimate:(BOOL)animate duration:(NSTimeInterval)duration {
    if (animate) {
        [UIView animateWithDuration:duration animations:^{
            [self dismissLeftView];
        }];
    } else {
        [self dismissLeftView];
    }

}

- (void)dismissLeftView {
    // 处理 mian 问题
    CGRect mainFrame = self.mainVCView.frame;
    mainFrame.origin.x = 0;
    self.mainVCView.frame = mainFrame;
    self.maskView.alpha = 0.0;
    // 处理 left 问题
    CGRect leftFrame = self.leftVCView.frame;
    leftFrame.origin.x = -MaginWidth/2;
    self.leftVCView.frame = leftFrame;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
