//
//  ViewController.m
//  IntelligentLock
//
//  Created by liangzhen on 2018/9/9.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "ViewController.h"
#import "Socket.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *sendText;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSocket];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)initSocket {
    __weak typeof (self)ws = self;
    Socket *socket = [Socket shareSocketWithHost:@"192.168.1.5" port:8000 messageBlack:^(NSData *message) {
        NSString * logStr = [[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString * log = [NSString stringWithFormat:@"%@\n%@",logStr,ws.logTextView.text];
            ws.logTextView.text = log;
        });
    }];
    if (socket.isConnect) {
        //开始心跳处理
        [self handleHeart];
    }
}

- (IBAction)sendAction:(UIButton *)sender {
    if (_sendText.text.length) {
        [[Socket shareSocket] sentMessage:_sendText.text progress:nil];
        _sendText.text = @"";
    }
}

- (void)handleHeart {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:15.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        UInt64 recordTime = [[NSDate date] timeIntervalSince1970];
        NSString * heartStr = [NSString stringWithFormat:@"heart:%llu", recordTime];
        [[Socket shareSocket] sentMessage:heartStr progress:nil];
    }];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
