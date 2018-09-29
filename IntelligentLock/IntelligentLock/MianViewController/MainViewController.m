//
//  MainViewController.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/9/29.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "MainViewController.h"
#import "StartView.h"
#import "Tools.h"
#import "LoginViewController.h"
#import "StartAnimationManger.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    // Do any additional setup after loading the view from its nib.
}

- (void)initView {
    StartView * startView = [StartView shareStartView];
    // 加在根视图上
    [KeyWindow.rootViewController.view addSubview:startView];
 
    //启动的时候先校验一次
    [self handleTouchIdVerb];
    //处理 启动页传来的事件
    [startView setStartBtnBlock:^(StartBtnActionType btnActionType) {
        if (btnActionType == StartBtnActionTypeTap) {
            // 是点击事件 先判断 是否可用？如果可用 就再次校验指纹 : 如果不可用直接去 账户密码登录
            [self handleTouchIdVerb];
        } else {
            // 是长按事件 账户密码登录
            [self presentLoginVC];
        }
    }];
    
}

/**
 处理指纹验证

 */
- (void)handleTouchIdVerb {
    __weak MainViewController * weakSelf = self;
    StartView * startView = [StartView shareStartView];
    // 开启指纹验证
    [[Tools shareTools] verbTouchIdResult:^(BOOL success, NSError *error) {
        if (success) {
            // 验证通过
            dispatch_async(dispatch_get_main_queue(), ^{
                [startView setStartRevolve:YES];
                // 2s 后停止旋转，展示
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [startView setStartRevolve:NO];
                });
                // 3s 后关闭 启动页
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[StartAnimationManger shareStartAnimationManger] startAnimationWithBackMainView:weakSelf.view startView:startView];
                });
            });
            
        } else {
            if (error.code > -1008) {
                // 需要 在 startView 上展示出错误的消息
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error.code == -1004) {
                        [startView alertTitle:@"指纹多次输入错误，请长按按钮使用账号密码登录"];
                    } else {
                        [startView alertTitle:error.userInfo[NSUnderlyingErrorKey]];
                    }
                });
            }
        }
    } replyAction:^(TouchIdReply reply) {
        if (reply == TouchIdReplyPasswordLogin) {
            // 弹出登录 界面
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf presentLoginVC];
            });
        }
    }];
}
- (void)presentLoginVC {
    LoginViewController * loginVC = [[LoginViewController alloc] init];
    [self presentViewController:loginVC animated:YES completion:nil];
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
