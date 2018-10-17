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
            // 网络状态
            self.netWorkState = NetWorkStateOn;
//            Socket *socket = [Socket shareSocket];
//            if (socket.socketConnectState != SocketConnectStateConnected && socket.canConnect == YES) {
//                //网络状态 改变 处于非链接状态 并且允许链接的情况下 才 重新连接
//                if (socket.socketConnectState == SocketConnectStateConnecting) {
//                    [socket setSocketConnectState:SocketConnectStateUnConnect];
//                }
//                [socket connectServer];
//            }
        } else {
            // 网络状态
            self.netWorkState = NetWorkStateOff;
            self.connectState = ConnectStateUnConnect;
        }
        // 重新连接
        [self connect];
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
            self.connectState = ConnectStateConnecting;
            if (self.lockStateBlock) {
                self.lockStateBlock(ConnectStateConnecting, BluetoothLockStateLock);
            }
            /*
             以后要优化一下 链接，每次进入App或者是网络状态发生改变时通过ping 来检查哪一个ip 可用？
             */
            // 如果是断线状态 就 连接
            //1. 优先本地网关链接 2.网关链接失败进行远程连接 3.网络连接失败，蓝牙链接
            __weak LockConnectManger * weakSelf = self;
            if (self.netWorkState == NetWorkStateOn) {
                // 去socket 链接
                [self socketConnectWithHost:@"192.168.1.120" port:8008 completion:^(SocketConnectState connectState) {
                    if (self.appIsAction) {
                        if (connectState == SocketConnectStateUnConnect) {
                            // 链接失败 换远程连接
                            [weakSelf socketConnectWithHost:@"144.34.162.116" port:8008 completion:^(SocketConnectState connectState) {
                                if (connectState == SocketConnectStateUnConnect) {
                                    // 远程连接失败，换蓝牙连接
                                    if (self.connectState == ConnectStateConnecting) {
                                        // 如果当前链接成功，不要重复链接
                                        [weakSelf blueToothConnect];
                                    }
                                }
                            }];
                        }
                    }
                }];
            } else {
                // 蓝牙连接
                [weakSelf blueToothConnect];
            }
           
            // 接收服务器返回的消息
            [[Socket shareSocket] setMessageBlack:^(NSDictionary *message) {
                MPNLog(@"%@",message);
                BluetoothLockState lockState = BluetoothLockStateLock;
                ConnectState connectState = ConnectStateUnConnect;
                if ([message[@"lockState"] isEqualToString:@"on"]) {
                    lockState = BluetoothLockStateUnLock;
                }
                if ([message[@"lockLink"] isEqualToString:@"on"]) {
                    connectState = weakSelf.connectState;
                }
                if (weakSelf.lockStateBlock) {
                    weakSelf.lockStateBlock(connectState, lockState);
                }
                if (weakSelf.gatewayConnectBlock) {
                    weakSelf.gatewayConnectBlock(connectState);
                }
            }];
        }
    }
}

- (void)socketConnectWithHost:(NSString *)host port:(int)port completion:(void(^)(SocketConnectState connectState))completion {
    // 使用socket 连接
    __weak LockConnectManger * weakSelf = self;
    [[Socket shareSocket] setCanConnect:YES]; //设置可以进行链接
    [Socket shareSocketWithHost:host port:port];
    [[Socket shareSocket] connectServerWithCompletion:^(SocketConnectState connectState) {
        if (connectState == SocketConnectStateConnected) {
            // 状态 刷新UI界面 1. 改变连接状态 2.将消息发送给接受者
            weakSelf.connectState = ConnectStateConnectedSocket;
            if (weakSelf.gatewayConnectBlock) {
                weakSelf.gatewayConnectBlock(ConnectStateConnectedSocket);
            }
            if (weakSelf.lockStateBlock) {
                weakSelf.lockStateBlock(ConnectStateConnectedSocket, BluetoothLockStateLock);
            }
        }
        
        if (completion) {
            completion(connectState);
        }
    }];
}

- (void)blueToothConnect {
    // 使用蓝牙连接
    __weak LockConnectManger * weakSelf = self;
    [[BluetoothCenter shareBluetoothCenter] bluetoothLockConnectCompletion:^(BluetoothLockLinkState state) {
        if (state == BluetoothLockLinkStateOn) {
            // 连接成功 1. 改变连接状态 2.将消息发送给接受者
            weakSelf.connectState = ConnectStateConnectedBluetooth;
            if (weakSelf.gatewayConnectBlock) {
                weakSelf.gatewayConnectBlock(ConnectStateConnectedBluetooth);
            }
            if (weakSelf.lockStateBlock) {
                weakSelf.lockStateBlock(ConnectStateConnectedBluetooth, BluetoothLockStateLock);
            }
        } else {
            // 连接失败 1. 改变连接状态 2.将消息发送给接受者
            weakSelf.connectState = ConnectStateUnConnect;
            if (weakSelf.gatewayConnectBlock) {
                weakSelf.gatewayConnectBlock(ConnectStateUnConnect);
            }
            if (weakSelf.lockStateBlock) {
                weakSelf.lockStateBlock(ConnectStateUnConnect, BluetoothLockStateLock);
            }
        }
    }];
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
                // 设置 断线状态
                self.connectState = ConnectStateUnConnect;
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
                MPNLog(@"%lu",(unsigned long)state);
                if (weakSelf.lockStateBlock) {
                    weakSelf.lockStateBlock(weakSelf.connectState, state);
                }
            }];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[BluetoothCenter shareBluetoothCenter] sendCommandState:NO completion:^(BluetoothLockState state) {
                    MPNLog(@"%lu",(unsigned long)state);
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
