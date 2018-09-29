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
    //设置风格
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    // Do any additional setup after loading the view.
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
