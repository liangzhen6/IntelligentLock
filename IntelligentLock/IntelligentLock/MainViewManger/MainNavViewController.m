//
//  MainNavViewController.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/9/28.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "MainNavViewController.h"
#import "MangerViewController.h"
#import <SVProgressHUD.h>
@interface MainNavViewController ()<UINavigationControllerDelegate>

@end

@implementation MainNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    [self initNavView];
    // Do any additional setup after loading the view.
}

- (void)initNavView {
    //设置风格 SVP 的风格
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [UINavigationBar appearance].translucent = YES;
    // 1.设置 导航栏的样式
    UIFont * navFont =[UIFont systemFontOfSize:18.0];
    UIColor * navTitleColor = [UIColor whiteColor];
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName:navFont,
                                     NSForegroundColorAttributeName:navTitleColor
                                     };
    [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
    // 设置 nav 的背景色
    [self.navigationBar setBarTintColor:RGBColor(63.0, 74.0, 246.0)];
    //2.设置返回按钮字体颜色为透明
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:17],
                                 NSForegroundColorAttributeName:[UIColor clearColor]
                                 };
    [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
 
}

#pragma mark --UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[MangerViewController shareMangerViewController] mainOpenLeftViewHidden:self.viewControllers.count > 1];
    
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
