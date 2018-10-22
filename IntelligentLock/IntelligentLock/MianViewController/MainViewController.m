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
#import "LockConnectManger.h"
#import "MainCollectionView.h"
#import "MainCollectionModel.h"
#import "SixEdgeView.h"
#import "DeviceDetailViewController.h"
#import "MangerViewController.h"
#import "User.h"
#import <SVProgressHUD.h>

@interface MainViewController ()
@property(nonatomic,strong)MainCollectionView * mainCollectionView;
@property (weak, nonatomic) IBOutlet UIView *MainHeaderView;
@property(nonatomic,strong)SixEdgeView * sixEdge;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    // Do any additional setup after loading the view from its nib.
}

- (void)initView {
    // 启动相关
    StartView * startView = [StartView shareStartView];
    // 加在根视图上
    [KeyWindow.rootViewController.view addSubview:startView];
    if ([[User shareUser] fingerprintLogin]) {
        // 已经登陆过了  直接验证指纹
        [self handleTouchIdVerb];
    } else {
        // 从来没有登陆过 就 密码账户登录
        [self presentLoginVC];
    }

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
    
    self.title = @"芝麻管家";
    //设置左侧菜单
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(showLeftMenu)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    // 页面布局相关
    //1.缩放的view
    CGFloat SEHeight = MainView_InsetY-80;
    CGFloat SEWidth = SEHeight*1.73/2;

    SixEdgeView * sixEdge = [[SixEdgeView alloc] initWithFrame:CGRectMake(Screen_Width/2-SEWidth/2, MainView_InsetY/2-SEHeight/2-10, SEWidth, SEHeight)];

    [self.MainHeaderView addSubview:sixEdge];
    _sixEdge = sixEdge;

    //2.uicollectionView 背后的view
    __block UIView * backView = [[UIView alloc] initWithFrame:CGRectMake(0, MainView_InsetY, Screen_Width, Screen_Height-NavBarHeight)];
    backView.backgroundColor = RGBColor(250.0, 249.0, 250.0);
    [self.view addSubview:backView];
    
    //3.uicollectionView
//    NSMutableArray * deviceDataArr = [[[User shareUser] devicesArr] mutableCopy];
    // 增加添加设备按钮
//    [deviceDataArr addObject:[MainCollectionModel mainCollectionModelWithTitle:@"增加设备" image:@"add" deviceCode:@"" modelType:CollectionModelTypeAddDevice]];
    NSArray * deviceDataArr = @[[MainCollectionModel mainCollectionModelWithTitle:@"增加设备" image:@"add" deviceCode:@"" modelType:CollectionModelTypeAddDevice]];
   
    __weak typeof (self)ws = self;
    MainCollectionView * mainCollectionView = [MainCollectionView mainCollectionViewWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height-NavBarHeight) DataSource:deviceDataArr selectBlock:^(MainCollectionModel *collectionModel) {
        [ws handlePushDevicePage:collectionModel];
    }];
    [mainCollectionView setContentInset:UIEdgeInsetsMake(MainView_InsetY, 0, 0, 0)];
    self.mainCollectionView = mainCollectionView;
    [mainCollectionView setScrollBlock:^(CGFloat scrollY, BOOL endScroll) {
//        MPNLog(@"%f*****%f",scrollY,MainView_InsetY);
        if (scrollY > -MainView_InsetY && scrollY <= 0) {
            if (endScroll) {
                // 停止滑动
                if (-scrollY < MainView_InsetY/2) {
                    [UIView animateWithDuration:0.3 animations:^{
                        backView.y = 0;
                        [ws.mainCollectionView setContentOffset:CGPointMake(0, 0)];
                        ws.sixEdge.transform = CGAffineTransformMakeScale(0.5, 0.5);
                        ws.sixEdge.alpha = 0.0;
                    }];
                } else {
                    [UIView animateWithDuration:0.3 animations:^{
                        backView.y = MainView_InsetY;
                        [ws.mainCollectionView setContentOffset:CGPointMake(0, -MainView_InsetY)];
                        ws.sixEdge.transform = CGAffineTransformMakeScale(1.0, 1.0);
                        ws.sixEdge.alpha = 1.0;
                    }];
                }
            } else {
                backView.y = -scrollY;
                CGFloat longY = MainView_InsetY/2 - (MainView_InsetY+scrollY);
                if (longY > MainView_InsetY/4) {
                    CGFloat scale = longY/(MainView_InsetY/2);
                    // 缩放
                    ws.sixEdge.transform = CGAffineTransformMakeScale(scale, scale);
                }
                // 处理透明度
                CGFloat alpha = longY/(MainView_InsetY/2);
                ws.sixEdge.alpha = alpha;
            }
            
        } else if (scrollY > 0) {
            backView.y = 0;
            ws.sixEdge.transform = CGAffineTransformMakeScale(0.5, 0.5);
            ws.sixEdge.alpha = 0.0;
        } else {
            backView.y = MainView_InsetY;
            ws.sixEdge.transform = CGAffineTransformMakeScale(1.0, 1.0);
            ws.sixEdge.alpha = 1.0;
        }
        
    }];
    [self.view addSubview:mainCollectionView];
    
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
            [weakSelf handleVerbSucessFingerprint:YES];
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

- (void)handleVerbSucessFingerprint:(BOOL)isFingerprint {
    // 登录成功了 是指纹仅仅把登录状态改一下就好了
    if (isFingerprint) {
        [[User shareUser] setLoginState:YES];
        [[User shareUser] writeUserMesage];
        [[NSNotificationCenter defaultCenter] postNotificationName:Login_State_Key object:nil userInfo:@{@"state":@"login"}];
    }
    
    StartView * startView = [StartView shareStartView];
    [self handleConnectManger];
    // 验证通过
    dispatch_async(dispatch_get_main_queue(), ^{
        [startView setStartRevolve:YES];
        // 2s 后停止旋转，展示
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [startView setStartRevolve:NO];
        });
        // 3s 后关闭 启动页
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[StartAnimationManger shareStartAnimationManger] startAnimationWithBackMainView:self.navigationController.view startView:startView];
        });
    });
}

- (void)presentLoginVC {
    LoginViewController * loginVC = [[LoginViewController alloc] init];
    loginVC.loginType = LoginVCTypeLogin;
    // 登录成功的回调
    [loginVC setSuccessBlock:^{
        [self handleVerbSucessFingerprint:NO];
    }];
    [self presentViewController:loginVC animated:YES completion:nil];
}
// 处理设备连接
- (void)handleConnectManger {
    __weak MainViewController * weakSelf = self;
    [[LockConnectManger shareLockConnectManger] setLockMangerCanConnect:YES];
    [[LockConnectManger shareLockConnectManger] connect];
    // 获取网关的链接状态
    [[LockConnectManger shareLockConnectManger] setGatewayConnectBlock:^(ConnectState connectState) {
        // 刷新UI状态
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.mainCollectionView updateConnectState:connectState];
            [weakSelf updateSixEdgeDeviceNum:connectState];
        });
    }];
}
// 更新链接设备的数量
- (void)updateSixEdgeDeviceNum:(ConnectState)connectState {
    if (connectState==ConnectStateConnectedBluetooth || connectState==ConnectStateConnectedSocket) {
        NSString * connectNum = [NSString stringWithFormat:@"%lu",[[self.mainCollectionView valueForKey:@"collectionData"] count]-1];
        [self.sixEdge updateDeviceNumber:connectNum];
    } else {
        [self.sixEdge updateDeviceNumber:@"0"];
    }
}

- (void)showLeftMenu {
    [[MangerViewController shareMangerViewController] showLeftViewAnimate:YES duration:0.3];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_sixEdge startAnimation];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_sixEdge endAnimation];
}
// 处理Device 页面的跳转等
- (void)handlePushDevicePage:(MainCollectionModel *)collectionModel {
    if ([[User shareUser] loginState]) {
        // 是登录状态才可以
        DeviceDetailViewController * deviceDetailVC = [[DeviceDetailViewController alloc] init];
        deviceDetailVC.deviceModel = collectionModel;
        [deviceDetailVC setDeviceBlock:^(DeviceBackType backType, MainCollectionModel *model) {
            [self.mainCollectionView handleDeviceItemChange:backType itemModel:model];
            [self updateSixEdgeDeviceNum:[[LockConnectManger shareLockConnectManger] connectState]];
        }];
        [self.navigationController pushViewController:deviceDetailVC animated:YES];
    } else {
        [SVProgressHUD showErrorWithStatus:@"登录状态下，才能添加设备！"];
        [SVProgressHUD dismissWithDelay:1.5];
    }

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
