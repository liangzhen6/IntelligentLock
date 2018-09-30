//
//  LeftMenuViewController.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/9/29.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "LeftMenuViewController.h"

@interface LeftMenuViewController ()

@end
/*
 菜单内 拥有的一些功能
 1.设置主体颜色
 2.开启指纹登录
 3.设置widget的一些快捷事件（开锁等。。）
 */
@implementation LeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBColor(39.0, 31.0, 61.0);
    // Do any additional setup after loading the view from its nib.
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
