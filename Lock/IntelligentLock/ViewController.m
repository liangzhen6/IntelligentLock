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

@interface ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *sendText;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UISwitch *lockLink;
@property (weak, nonatomic) IBOutlet UITextField *lockState;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSocket];
    [self initView];

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)initView {
    _sendText.delegate = self;
    _sendText.returnKeyType = UIReturnKeySend;
    _sendText.enablesReturnKeyAutomatically = YES;
    
    // 监听  链接 状态
    [[Socket shareSocket] addObserver:self forKeyPath:@"socketConnectType" options:NSKeyValueObservingOptionNew context:nil];
    [self.lockState addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"socketConnectType"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[Socket shareSocket] socketConnectType] == connectedConnectType) {
                self.lockLink.on = YES;
            } else {
                self.lockLink.on = NO;
            }
        });
    } else if ([keyPath isEqualToString:@"text"]) {
        // 锁的状态发生改变 发送消息给服务器
        [self sendMessage];
    }
}

- (void)initSocket {
    __weak typeof (self)ws = self;
    [Socket shareSocketWithHost:@"192.168.1.104" port:8000 messageBlack:^(NSDictionary *message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString * mes = message[@"Mes"];
            if ([mes length]) {
                NSString * log = [NSString stringWithFormat:@"%@\n%@",mes,ws.logTextView.text];
                ws.logTextView.text = log;
            }
            NSLog(@"接收到的消息：%@",message);
            if ([message[@"Mtype"] isEqualToString:@"command"]) {
                if ([mes isEqualToString:@"on"]) {
                    [ws handleOpenLock];
                }
            }
        });
    }];
    
    //开始心跳处理
    [self handleHeart];
}
//开锁
- (void)handleOpenLock {
    self.lockState.text = @"opening";
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.lockState.text = @"on";
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.lockState.text = @"off";
    });
    
}

- (void)sendMessage {
    NSString * lockLink = @"off";
    if (self.lockLink.on) {
        lockLink = @"on";
    }
    MesModel *model = [MesModel mesModelType:commandMType message:self.lockState.text lockLink:lockLink lockState:self.lockState.text];
    NSLog(@"发出消息%@",model);
    [[Socket shareSocket] sentMessage:model progress:nil];
    _sendText.text = @"";
}

- (void)handleHeart {
    __weak typeof (self) ws = self;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:15.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        UInt64 recordTime = [[NSDate date] timeIntervalSince1970];
        NSString * heartStr = [NSString stringWithFormat:@"%llu", recordTime];
        NSString * lockLink = @"off";
        if (ws.lockLink.on) {
            lockLink = @"on";
        }
        MesModel * model = [MesModel mesModelType:heartMType message:heartStr lockLink:lockLink lockState:ws.lockState.text];
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
