 //
//  Socket.m
//  SocketTest
//
//  Created by shenzhenshihua on 2017/2/24.
//  Copyright © 2017年 shenzhenshihua. All rights reserved.
//

#import "Socket.h"
#import <GCDAsyncSocket.h>
#import "MesModel.h"
#import "Tools.h"

@interface Socket ()<GCDAsyncSocketDelegate>
@property(nonatomic,strong)GCDAsyncSocket *asyncSocket;
@property(nonatomic,copy)NSString * host;
@property(nonatomic,assign)int port;
@property(nonatomic,assign)NSInteger afterTimeConnect;
//@property(nonatomic,strong)NSMutableArray * allSendMessage;
@end
static Socket * _socket = nil;

@implementation Socket

+ (id)shareSocket {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_socket == nil) {
            _socket = [[Socket alloc] init];
        }
    });
    return _socket;
}

+ (id)shareSocketWithHost:(NSString *)host port:(int)port messageBlack:(void(^)(NSString *message))messageBlack {
    Socket * socket = [Socket shareSocket];
    socket.host = host;
    socket.port = port;
    socket.afterTimeConnect = 0;
    socket.messageBlack = messageBlack;
    [socket connectServer];
    return socket;
}
- (id)init {
    self = [super init];
    if (self) {
        _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return self;
}

- (void)connectServer {
    if (_host.length && _port > 0) {
        if (_socketConnectType == unConnectConnectType) {
            NSError *error = nil;
            _socketConnectType = connectingConnectType;
            [_asyncSocket connectToHost:_host onPort:_port withTimeout:5.0 error:&error];
            if (error) {
                NSLog(@"%@",error);
            }
        }
    }
}

- (void)closeConnectServer {
    if (_socketConnectType == connectedConnectType) {
        MesModel *model = [MesModel mesModelType:commandMType message:@"exit"];
        [self sentMessage:model progress:nil];
    }
}

- (void)sentMessage:(MesModel *)model progress:(void(^)(float progress))progressBlock {
    if (_socketConnectType == connectedConnectType) {
        //是链接状态才会发送心跳包
        NSMutableDictionary * sendDict = [[NSMutableDictionary alloc] init];
        UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
        switch (model.type) {
            case heartMType:
            {//是心跳包
                [sendDict setObject:@"heart" forKey:@"Mtype"];
            }
                break;
            case commandMType:
            {//是指令
                [sendDict setObject:@"command" forKey:@"Mtype"];
            }
                break;
            default:
                break;
        }
        [sendDict setObject:model.mes forKey:@"Mes"];
        
        NSData *mData = [NSJSONSerialization dataWithJSONObject:sendDict options:NSJSONWritingPrettyPrinted error:nil];
        NSString * jsonStr = [[NSString alloc] initWithData:mData encoding:NSUTF8StringEncoding];
        
        NSData * base64Data = [[Tools shareTools] encryptData:jsonStr];
        [_asyncSocket writeData:base64Data withTimeout:-1 tag:(long)recordTime];
    }
}


#pragma mark =============GCDAsyncSocket delegate=================
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"已经连接到host=%@=========port=%d",host,port);
    //更改连接状态
    _socketConnectType = connectedConnectType;
    // 开始准备接收消息
    [_asyncSocket readDataWithTimeout:-1 tag:100];
    // 初始化 重新连接的时间
    _afterTimeConnect = 0;
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    if (data.length) {
        NSData * jsonData = [[Tools shareTools] decryptData:data];
       
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
        NSString * mesStr = dict[@"Mes"];
        if ([mesStr length]) {
            if (self.messageBlack) {
                self.messageBlack(mesStr);
            }
        }
    }
    
    [sock readDataWithTimeout:-1 tag:100];

}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"%@----已经发送消息---%@",sock,_asyncSocket);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err {
    NSLog(@"socket:%@已经断开连接，错误:%@",sock,err);
    _socketConnectType = unConnectConnectType;
    if (_appIsAction) {
        //处理 重连问题
        [self handleReConnect];
    }
}
//处理 重新链接机制
- (void)handleReConnect {
    _afterTimeConnect = _afterTimeConnect + 2;
    NSLog(@"%ld：秒后发起重连！",(long)_afterTimeConnect);
    __weak typeof (self) ws = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_afterTimeConnect * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //重新连接操作
        [ws connectServer];
    });
}

//- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
//
////    [self.socketArray addObject:newSocket];
//    [newSocket readDataWithTimeout:-1 tag:100];
//}



//- (NSMutableArray *)socketArray {
//    if (_socketArray==nil) {
//        _socketArray = [[NSMutableArray alloc] init];
//    }
//   return _socketArray;
//}

//- (NSMutableArray *)allSendMessage {
//    if (_allSendMessage==nil) {
//        _allSendMessage = [[NSMutableArray alloc] init];
//    }
//    return _allSendMessage;
//}

@end
