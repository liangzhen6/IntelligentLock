//
//  DeviceDetailViewController.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/10/13.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "DeviceDetailViewController.h"
#import "MainCollectionModel.h"
#import "LockConnectManger.h"

@interface DeviceDetailViewController ()
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *desLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mainIcon;
@property (weak, nonatomic) IBOutlet UIButton *switchConnectBtn;

@end

@implementation DeviceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.deviceModel.title;
    [self initView];
    if (self.deviceModel.modelType == CollectionModelTypeDevice) {
        // 是设备连接状态就 设置监听。。设备的状态
        [self initVerbLockState];
    }
//    self.view.backgroundColor = RGBColor(51.0, 66.0, 212.0);
    // Do any additional setup after loading the view from its nib.
}

- (void)initView {
    // 为topView 切圆角 设置阴影
    self.topView.layer.cornerRadius = (Screen_Width-160)/2;
    self.topView.layer.borderWidth = 2;
    if (self.deviceModel.modelType == CollectionModelTypeAddDevice) {
        self.topView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.mainIcon.image = [UIImage imageNamed:@"add_detail"];
        self.desLabel.text = @"点击上方按钮添加新设备~";
        self.switchConnectBtn.hidden = YES;
    } else {
        self.switchConnectBtn.hidden = NO;
        [self.switchConnectBtn setImageEdgeInsets:UIEdgeInsetsMake(-20, 0, 0, -30)];
        [self.switchConnectBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -30, -35, 0)];
        self.switchConnectBtn.layer.cornerRadius = 30;
        self.switchConnectBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.switchConnectBtn.layer.borderWidth = 1;
        
        self.topView.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.switchConnectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        [self setConnectTypeUI:self.deviceModel.connectState];
    }
    
//    self.topView.layer.shadowRadius = 30;
//    self.topView.layer.shadowOffset = CGSizeMake(0, 0);
//    self.topView.layer.shadowColor = [UIColor whiteColor].CGColor;
//    self.topView.layer.shadowOpacity = 1.0;
    
    
}
// 设置不同链接方式的UI
- (void)setConnectTypeUI:(ConnectState)state {
    if (state == ConnectStateConnectedSocket) {
        // 设备网络链接
        self.desLabel.text = @"设备网络连接~";
        [self.switchConnectBtn setImage:[[UIImage imageNamed:@"switch"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [self.switchConnectBtn setTitle:@"开关" forState:UIControlStateNormal];
        
    } else if (state == ConnectStateConnectedBluetooth) {
        // 设备蓝牙连接
        self.desLabel.text = @"设备蓝牙连接~";
        [self.switchConnectBtn setImage:[[UIImage imageNamed:@"switch"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [self.switchConnectBtn setTitle:@"开关" forState:UIControlStateNormal];
        
    } else {
        // 未连接
        if (state == ConnectStateConnecting) {
            self.desLabel.text = @"设备连接中....";
        } else {
            self.desLabel.text = @"设备断开连接~";
        }
        [self.switchConnectBtn setImage:[[UIImage imageNamed:@"connect"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [self.switchConnectBtn setTitle:@"重连" forState:UIControlStateNormal];
    }
}

- (void)setLockStateUI:(BluetoothLockState)state {
    if (state == BluetoothLockLinkStateOff) {
        // 是关闭的
        [self.mainIcon setImage:[UIImage imageNamed:@"lock-off"]];
    } else {
        // 被打开了
        [self.mainIcon setImage:[UIImage imageNamed:@"lock-on"]];
    }
}

- (void)initVerbLockState {
    __weak typeof (self)ws = self;
    [[LockConnectManger shareLockConnectManger] setLockStateBlock:^(ConnectState connectState, BluetoothLockState lockState) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws setConnectTypeUI:connectState];
            [ws setLockStateUI:lockState];
        });
    }];
}

- (IBAction)switchConnectAction:(UIButton *)sender {
    if (self.deviceModel.connectState == ConnectStateUnConnect) {
        // 发起重新连接
        [[LockConnectManger shareLockConnectManger] connect];
    } else {
        // 发送开锁命令
        [[LockConnectManger shareLockConnectManger] openLock];
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
