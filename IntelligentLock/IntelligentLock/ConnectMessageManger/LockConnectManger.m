//
//  LockConnectManger.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/9/26.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "LockConnectManger.h"
#import <AFNetworking.h>
#import "Socket.h"
#import "BluetoothCenter.h"
#import "MesModel.h"

@interface LockConnectManger ()

@end
static LockConnectManger * _lockConnectManger;

@implementation LockConnectManger
+ (id)shareLockConnectManger {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_lockConnectManger == nil) {
            _lockConnectManger = [[LockConnectManger alloc] init];
        }
    });
    return _lockConnectManger;
}

- (void)observeReachabilityStatus {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
            Socket *socket = [Socket shareSocket];
            if (socket.socketConnectState != SocketConnectStateConnected && socket.canConnect == YES) {
                //网络状态 改变 处于非链接状态 并且允许链接的情况下 才 重新连接
                if (socket.socketConnectState == SocketConnectStateConnecting) {
                    [socket setSocketConnectState:SocketConnectStateUnConnect];
                }
                [socket connectServer];
            }

        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)willResignActive {
    [self setAppIsAction:NO];
    //断开连接
    [self closeConnect];
}

- (void)didBecomeActive {
    [self setAppIsAction:YES];
    // 开始连接
    [self connect];
}

- (void)connect {
    if (_lockMangerCanConnect) {
        // 允许链接的时候才链接
        if (self.connectState == ConnectStateUnConnect) {
            // 如果是断线状态 就 连接
            // 1.先尝试 蓝牙连接
            __weak LockConnectManger * weakSelf = self;
            [[BluetoothCenter shareBluetoothCenter] bluetoothLockConnectCompletion:^(BluetoothLockLinkState state) {
                if (state == BluetoothLockLinkStateOn) {
                    weakSelf.connectState = ConnectStateConnectedBluetooth;
                    // 如果socket 已经连接 把socket 关闭
                    if (weakSelf.connectState == ConnectStateConnectedSocket) {
                        [[Socket shareSocket] setCanConnect:NO];
                        [[Socket shareSocket] closeConnect];
                    }
                } else {
                    // 如果是 不能连接状态 就使用socket 连接
                    [[Socket shareSocket] setCanConnect:YES]; //设置可以进行链接
                    [Socket shareSocketWithHost:@"192.168.1.120" port:8008];
                    [[Socket shareSocket] connectServerWithCompletion:^(SocketConnectState connectState) {
                        if (connectState == SocketConnectStateConnected) {
                            weakSelf.connectState = ConnectStateConnectedSocket;
                        } else {
                            weakSelf.connectState = ConnectStateUnConnect;
                        }
                    }];
                    // 服务器返回的消息
                    [[Socket shareSocket] setMessageBlack:^(NSDictionary *message) {
                        NSLog(@"%@",message);
                        BluetoothLockState lockState = BluetoothLockStateLock;
                        if ([message[@"lockState"] isEqualToString:@"on"]) {
                            lockState = BluetoothLockStateUnLock;
                        }
                        
                        if (weakSelf.lockStateBlock) {
                            weakSelf.lockStateBlock(weakSelf.connectState, lockState);
                        }
                    }];
                }
            }];
        }
    }
}

- (void)closeConnect {
    switch (self.connectState) {
        case ConnectStateConnectedBluetooth:
            {// 目前是蓝牙连接的
                
            }
            break;
        case ConnectStateConnectedSocket:
            {// 目前是socket连接的
                [[Socket shareSocket] setCanConnect:NO];
                [[Socket shareSocket] closeConnectServer];
            }
            break;
        default:
            break;
    }
}

- (void)openLock {
    __weak LockConnectManger * weakSelf = self;
    switch (self.connectState) {
        case ConnectStateConnectedBluetooth:
        {// 目前是蓝牙连接的
            [[BluetoothCenter shareBluetoothCenter] sendCommandState:YES completion:^(BluetoothLockState state) {
                NSLog(@"%lu",(unsigned long)state);
                if (weakSelf.lockStateBlock) {
                    weakSelf.lockStateBlock(weakSelf.connectState, state);
                }
            }];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[BluetoothCenter shareBluetoothCenter] sendCommandState:NO completion:^(BluetoothLockState state) {
                    NSLog(@"%lu",(unsigned long)state);
                    if (weakSelf.lockStateBlock) {
                        weakSelf.lockStateBlock(weakSelf.connectState, state);
                    }
                }];
            });

        }
            break;
        case ConnectStateConnectedSocket:
        {// 目前是socket连接的 指令 ff开  00关 一般是发送开的，关闭是 自动的
            MesModel * model = [MesModel mesModelType:commandMType message:@"ff" lockLink:nil lockState:nil];
            [[Socket shareSocket] sentMessage:model progress:nil];
        }
            break;
        default:
            break;
    }
}

@end
