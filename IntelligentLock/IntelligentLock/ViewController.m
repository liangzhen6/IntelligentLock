//
//  ViewController.m
//  IntelligentLock
//
//  Created by liangzhen on 2018/9/9.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "ViewController.h"
#import "Socket.h"
#import "MesModel.h"
#import "LockConnectManger.h"
#import "BluetoothCenter.h"
#import "StartView.h"
#import "StartAnimationManger.h"
@interface ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *sendText;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self initSocket];
    self.view.backgroundColor = [UIColor whiteColor];
    [[LockConnectManger shareLockConnectManger] connect];
    [self initView];
    // Do any additional setup after loading the view, typically from a nib.
}
//- (BOOL)prefersStatusBarHidden
//{
//    return YES;//隐藏为YES，显示为NO
//}
- (void)initView {
    _sendText.delegate = self;
    _sendText.returnKeyType = UIReturnKeySend;
    _sendText.enablesReturnKeyAutomatically = YES;
    
    StartView *start = [StartView shareStartView];
    [KeyWindow addSubview:start];
}

- (void)initSocket {
    __weak typeof (self)ws = self;
    [Socket shareSocketWithHost:@"192.168.1.104" port:8008 messageBlack:^(NSDictionary *message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString * mesStr = message[@"Mes"];
            if ([mesStr length]) {
                NSString * log = [NSString stringWithFormat:@"%@--%@\n%@",mesStr, message[@"lockState"],ws.logTextView.text];
                ws.logTextView.text = log;
            }
            MPNLog(@"%@",message);
        });
    }];
    
    //开始心跳处理
    [self handleHeart];
}

- (IBAction)sendAction:(UIButton *)sender {
    [self sendMessage];
}

- (void)sendMessage {
    if (_sendText.text.length) {
        MesModel *model = [MesModel mesModelType:commandMType message:_sendText.text lockLink:nil lockState:nil];
        [[Socket shareSocket] sentMessage:model progress:nil];
        _sendText.text = @"";
    }
}

- (void)handleHeart {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:15.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        UInt64 recordTime = [[NSDate date] timeIntervalSince1970];
        NSString * heartStr = [NSString stringWithFormat:@"%llu", recordTime];
        MesModel * model = [MesModel mesModelType:heartMType message:heartStr lockLink:nil lockState:nil];
        [[Socket shareSocket] sentMessage:model progress:nil];
    }];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

#pragma mark --- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendMessage];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [[BluetoothCenter shareBluetoothCenter] sendCommandState:YES completion:^(BluetoothLockState state) {
        NSLog(@"%lu",(unsigned long)state);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[BluetoothCenter shareBluetoothCenter] sendCommandState:NO completion:^(BluetoothLockState state) {
            NSLog(@"%lu",(unsigned long)state);
        }];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
