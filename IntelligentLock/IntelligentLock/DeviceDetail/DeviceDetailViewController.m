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
#import <SVProgressHUD.h>
#import "User.h"
#import "Tools.h"
#import "AlertConreoller.h"
#import "QRCodeIdentifyVC.h"
#import "ShareDeviceViewController.h"

@interface DeviceDetailViewController ()
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *desLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mainIcon;
@property (weak, nonatomic) IBOutlet UIButton *switchConnectBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteDeviceBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareDeviceBtn;
@property (weak, nonatomic) IBOutlet UIView *onlineView;
@property (weak, nonatomic) IBOutlet UILabel *onlineTitle;
@property (weak, nonatomic) IBOutlet UIImageView *onlineIcon;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@property(nonatomic,assign)CollectionModelType collectionModelType;
@property(nonatomic,assign)ConnectState connectState;

@property(nonatomic,strong)CAShapeLayer * topViewMainShapeLayer;
@end

@implementation DeviceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
//    self.view.backgroundColor = RGBColor(51.0, 66.0, 212.0);
    // Do any additional setup after loading the view from its nib.
}
- (void)initData {
    self.collectionModelType = self.deviceModel.modelType;
    self.connectState = self.deviceModel.connectState;
    
    if (self.collectionModelType == CollectionModelTypeDevice) {
        // 是设备连接状态就 设置监听。。设备的状态
        [self initVerbLockState];
    }
}
- (void)initView {    
    CAShapeLayer * shapeLayer = [self getShapeLayerWithProgress:1.0];
    [self.topView.layer addSublayer:shapeLayer];
    self.topViewMainShapeLayer = shapeLayer;
    
    [self.switchConnectBtn setImageEdgeInsets:UIEdgeInsetsMake(-20, 0, 0, -32)];
    [self.switchConnectBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -30, -35, 0)];
    self.switchConnectBtn.layer.cornerRadius = 30;
    self.switchConnectBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.switchConnectBtn.layer.borderWidth = 1;
    [self.switchConnectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.deleteDeviceBtn setImageEdgeInsets:UIEdgeInsetsMake(-20, 0, 0, -35)];
    [self.deleteDeviceBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -30, -35, 0)];
    self.deleteDeviceBtn.layer.cornerRadius = 30;
    self.deleteDeviceBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.deleteDeviceBtn.layer.borderWidth = 1;
    [self.deleteDeviceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.shareDeviceBtn setImageEdgeInsets:UIEdgeInsetsMake(-20, 0, 0, -32)];
    [self.shareDeviceBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -30, -35, 0)];
    self.shareDeviceBtn.layer.cornerRadius = 30;
    self.shareDeviceBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.shareDeviceBtn.layer.borderWidth = 1;
    [self.shareDeviceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // 小标签的样式
    self.onlineView.layer.cornerRadius = 3;
    self.onlineView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.onlineView.layer.borderWidth = 1;
    
//    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.onlineView];
//    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self setMainViewStyle];
}

- (void)setMainViewStyle {

    self.progressLabel.hidden = YES;
    self.mainIcon.hidden = NO;
    if (self.collectionModelType == CollectionModelTypeAddDevice) {
        self.title = @"增加设备";
        self.topViewMainShapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
        self.mainIcon.image = [UIImage imageNamed:@"add_detail"];
        self.desLabel.text = @"点击上方按钮添加新设备~";
        self.switchConnectBtn.hidden = YES;
        self.deleteDeviceBtn.hidden = YES;
        self.shareDeviceBtn.hidden = YES;
        self.onlineView.hidden = YES;
    } else {
        self.title = @"智能门禁";
        self.mainIcon.image = [UIImage imageNamed:@"lock-off"];
        self.switchConnectBtn.hidden = NO;
        self.deleteDeviceBtn.hidden = NO;
        self.shareDeviceBtn.hidden = NO;
        self.onlineView.hidden = NO;
        self.topViewMainShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        [self setConnectTypeUI:self.connectState];
    }
}

// 设置不同链接方式的UI
- (void)setConnectTypeUI:(ConnectState)state {
    if (state == ConnectStateConnectedSocket) {
        // 设备网络链接
        self.desLabel.text = @"设备网络连接~";
        self.onlineTitle.text = @"在线";
        self.onlineTitle.textColor = [UIColor whiteColor];
        self.onlineIcon.image = [UIImage imageNamed:@"wifi-big"];
        if (self.deviceModel.bunAllDevice == YES) {
            [self.switchConnectBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [self.switchConnectBtn setImage:[[UIImage imageNamed:@"switch_glay"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        } else {
            [self.switchConnectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.switchConnectBtn setImage:[[UIImage imageNamed:@"switch"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        }
        [self.switchConnectBtn setTitle:@"开关" forState:UIControlStateNormal];
        
    } else if (state == ConnectStateConnectedBluetooth) {
        // 设备蓝牙连接
        self.desLabel.text = @"设备蓝牙连接~";
        self.onlineTitle.text = @"在线";
        self.onlineTitle.textColor = [UIColor whiteColor];
        self.onlineIcon.image = [UIImage imageNamed:@"ble-big"];
        if (self.deviceModel.bunAllDevice == YES) {
            [self.switchConnectBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [self.switchConnectBtn setImage:[[UIImage imageNamed:@"switch_glay"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        } else {
            [self.switchConnectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.switchConnectBtn setImage:[[UIImage imageNamed:@"switch"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        }
        [self.switchConnectBtn setTitle:@"开关" forState:UIControlStateNormal];
        
    } else {
        // 未连接
        if (state == ConnectStateConnecting) {
            self.desLabel.text = @"设备连接中....";
        } else {
            self.desLabel.text = @"设备断开连接~";
        }
        self.onlineTitle.text = @"离线";
        self.onlineTitle.textColor = [UIColor redColor];
        self.onlineIcon.image = [UIImage imageNamed:@"off-line-big"];
        [self.switchConnectBtn setImage:[[UIImage imageNamed:@"connect"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [self.switchConnectBtn setTitle:@"重连" forState:UIControlStateNormal];
    }
    
    //设置分享按钮的样式
    if (self.deviceModel.bunAllDevice == YES) {
        [self.shareDeviceBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.shareDeviceBtn setImage:[[UIImage imageNamed:@"share_device_glay"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    } else {
        [self.shareDeviceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.shareDeviceBtn setImage:[[UIImage imageNamed:@"share_device"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
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
        if (ws.connectState != connectState) {
            ws.connectState = connectState;
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws setConnectTypeUI:connectState];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws setLockStateUI:lockState];
        });
    }];
}

- (IBAction)switchConnectAction:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
            {//开关按钮
                if (self.deviceModel.bunAllDevice == YES) {
                    // 设备被禁止使用
                    [SVProgressHUD showErrorWithStatus:@"设备已禁止使用！"];
                    [SVProgressHUD dismissWithDelay:1.5];
                } else {
                    if (self.deviceModel.connectState == ConnectStateUnConnect) {
                        // 发起重新连接
                        [[LockConnectManger shareLockConnectManger] connect];
                    } else {
                        // 发送开锁命令
                        [[LockConnectManger shareLockConnectManger] openLock];
                    }
                    
                    // 防止暴力点击
                    sender.userInteractionEnabled = NO;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        sender.userInteractionEnabled = YES;
                    });
                }
            }
            break;
        case 1:
            {//删除按钮
                [AlertConreoller alertControllerWithController:self title:@"提示" message:@"确定要删除当前设备吗？" cancelButtonTitle:@"再想想" otherButtonTitle:@"确定" cancelAction:nil otherAction:^{
                    // 执行删除操作
                    self.collectionModelType = CollectionModelTypeAddDevice;
                    [self setMainViewStyle];
                    // 通知 home 页面要删除一个
                    if (self.deviceBlock) {
                        self.deviceBlock(DeviceBackTypeDeleteDevice, self.deviceModel);
                    }
                }];
            }
            break;
        case 2:
            {//分享按钮
                if (self.deviceModel.bunAllDevice == YES) {
                    // 设备被禁止使用
                    [SVProgressHUD showErrorWithStatus:@"设备已禁止使用！"];
                    [SVProgressHUD dismissWithDelay:1.5];
                } else {
                    ShareDeviceViewController * shareDeviceVC = [[ShareDeviceViewController alloc] init];
                    shareDeviceVC.deviceModel = self.deviceModel;
                    [self.navigationController pushViewController:shareDeviceVC animated:YES];
                }
            }
            break;
        default:
            break;
    }
 
}
- (IBAction)addDeviceAction:(UITapGestureRecognizer *)sender {
    if (self.collectionModelType == CollectionModelTypeAddDevice) {
        // 是增加一个设备
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction * alertAction1 = [UIAlertAction actionWithTitle:@"扫描二维码添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            __weak typeof (self) ws = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                QRCodeIdentifyVC * qrCodeIdentifyVC = [[QRCodeIdentifyVC alloc] init];
                [qrCodeIdentifyVC setIdentifyBlock:^(NSString *resulrStr) {
                    if ([resulrStr length]) {
                        NSData * deData = [[Tools shareTools] decryptData:[resulrStr dataUsingEncoding:NSUTF8StringEncoding]];
                        
                        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:deData options:NSJSONReadingAllowFragments error:nil];
                        if ([dict count]) {
                            [ws handleAddDeviceWithDict:dict];
                        }
                    } else {
                        [SVProgressHUD showErrorWithStatus:@"二维码扫描失败"];
                        [SVProgressHUD dismissWithDelay:1.0];
                    }
                }];
                [self.navigationController pushViewController:qrCodeIdentifyVC animated:YES];
            });
            
        }];
        UIAlertAction * alertAction2 = [UIAlertAction actionWithTitle:@"输入设备编码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIAlertController * alertTextController = [UIAlertController alertControllerWithTitle:nil message:@"请输入设备的编码" preferredStyle:UIAlertControllerStyleAlert];
            __block UITextField * codeTextField = nil;
            [alertTextController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                codeTextField = textField;
            }];
            UIAlertAction * alertActionDone = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (codeTextField) {
                    NSDictionary * dict = @{@"expiredTime":@"never", @"deviceCode":codeTextField.text};
                    [self handleAddDeviceWithDict:dict];
                }
            }];
            UIAlertAction * alertActionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alertTextController addAction:alertActionDone];
            [alertTextController addAction:alertActionCancel];
            [self presentViewController:alertTextController animated:YES completion:nil];
        }];
        UIAlertAction * alertAction3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:alertAction1];
        [alertController addAction:alertAction2];
        [alertController addAction:alertAction3];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
}

- (void)handleAddDeviceWithDict:(NSDictionary *)messageDict {
    if ([[LockConnectManger shareLockConnectManger] netWorkState] == NetWorkStateOn) {
        /*
         expiredTime":self.timeStr, @"deviceCode"
         */
        NSString * deviceCode = messageDict[@"deviceCode"];
        NSString * expiredTime = messageDict[@"expiredTime"];
        if (![expiredTime isEqualToString:@"never"]) {
            NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
            NSDate * selectTime = [formatter dateFromString:expiredTime];
            NSDate * currentDate = [NSDate date];
            NSComparisonResult result = [selectTime compare:currentDate];
            if (result == NSOrderedAscending) {
                // 已经过期
                [SVProgressHUD showErrorWithStatus:@"设备分享已过期！"];
                [SVProgressHUD dismissWithDelay:1.0];
                
                return;
            }
        }
        
        if ([deviceCode length] && [deviceCode isEqualToString:@"ZMGJS0001"]) {
            for (MainCollectionModel * model in [[User shareUser] devicesArr]) {
                if ([model.deviceCode isEqualToString:deviceCode]) {
                    [SVProgressHUD showErrorWithStatus:@"当前设备已经添加请勿重复添加！"];
                    [SVProgressHUD dismissWithDelay:1.0];
                    return;
                }
            }
            __weak typeof (self) ws = self;
            [self updateAddDeviceProgressComple:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    ws.connectState = ConnectStateConnectedSocket;
                    ws.collectionModelType = CollectionModelTypeDevice;
                    [ws setMainViewStyle];
                    [ws initVerbLockState];
                    // 通知 home 页面要增加一个
                    if (ws.deviceBlock) {
                        MainCollectionModel *model = [MainCollectionModel mainCollectionModelWithTitle:@"智能门禁" image:@"lock" deviceCode:deviceCode expiredTime:expiredTime bunAllDevice:[[User shareUser] closeAllDevice] modelType:CollectionModelTypeDevice];
                        model.connectState = ws.connectState;
                        ws.deviceBlock(DeviceBackTypeAddDevice, model);
                    }
                });
            }];
        } else {
            // 请输入正确的 设备编码
            [SVProgressHUD showErrorWithStatus:@"请输入正确的设备编码!"];
            [SVProgressHUD dismissWithDelay:1.0];
        }
    } else {
        [SVProgressHUD showErrorWithStatus:@"请检查网络是否连接？"];
        [SVProgressHUD dismissWithDelay:1.0];
    }
    
}

- (void)updateAddDeviceProgressComple:(void(^)(void))comple {
    // topView 的 logo 隐藏 进度条展示
    self.mainIcon.hidden = YES;
    self.progressLabel.hidden = NO;
    self.desLabel.text = @"设备添加中...";
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block CAShapeLayer * lastLayer = nil;
        __weak typeof (self) ws = self;
        __block float progress = 0.0;
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.02 repeats:YES block:^(NSTimer * _Nonnull timer) {
            if (progress < 1.0) {
                progress += 0.01;
                CAShapeLayer * layer = [self getShapeLayerWithProgress:progress];
                layer.strokeColor = [UIColor whiteColor].CGColor;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (lastLayer) {
                        [lastLayer removeFromSuperlayer];
                        lastLayer = nil;
                    }
                    ws.progressLabel.text = [NSString stringWithFormat:@"%d%%",(int)(progress*100)];
                    [ws.topView.layer addSublayer:layer];
                    lastLayer = layer;
                });
            } else {
                [timer invalidate];// 停止定时器
                if (comple) {
                    comple();
                }
            }
        }];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] run];
    });
}
- (CAShapeLayer *)getShapeLayerWithProgress:(float)progress {
    CGFloat topViewW = (Screen_Width-160)/2;
    CGPoint center = CGPointMake(topViewW, topViewW);
    
    CGFloat startA = -M_PI_2;// 开始角度
    CGFloat endA = -M_PI_2 + M_PI * 2 * progress;// 结束角度
    UIBezierPath * bezierPath = [UIBezierPath bezierPathWithArcCenter:center radius:topViewW-2 startAngle:startA endAngle:endA clockwise:YES];
    
    CAShapeLayer * shaperLayer = [CAShapeLayer layer];
    shaperLayer.frame = CGRectMake(0, 0, topViewW, topViewW);
    shaperLayer.fillColor = [UIColor clearColor].CGColor;
//    shaperLayer.strokeColor = color.CGColor; //< 线的颜色
    shaperLayer.opacity = 1.0;
    shaperLayer.lineWidth = 2;
    
    shaperLayer.path = bezierPath.CGPath;
    
    return shaperLayer;
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
