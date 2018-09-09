//
//  Socket.m
//  SocketTest
//
//  Created by shenzhenshihua on 2017/2/24.
//  Copyright © 2017年 shenzhenshihua. All rights reserved.
//

#import "Socket.h"
#import <GCDAsyncSocket.h>

@interface Socket ()<GCDAsyncSocketDelegate>
@property(nonatomic,strong)GCDAsyncSocket *asyncSocket;
@property(nonatomic,copy)NSString * host;
@property(nonatomic)int port;

@property(nonatomic,strong)NSMutableArray * allSendMessage;
@end


@implementation Socket

+ (id)shareSocket {
    static Socket * socket;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        socket = [[Socket alloc] init];
    });
    return socket;
}

+ (id)shareSocketWithHost:(NSString *)host port:(int)port messageBlack:(void(^)(NSData *message))messageBlack {
    Socket * socket = [Socket shareSocket];
    socket.host = host;
    socket.port = port;
    socket.messageBlack = messageBlack;
    NSError *error = nil;
    socket.isConnect = [socket.asyncSocket connectToHost:host onPort:port error:&error];
    if (socket.isConnect) {
        [socket.asyncSocket readDataWithTimeout:-1 tag:100];
    } else {
        NSLog(@"链接失败！");
    }
    if (error) {
        NSLog(@"%@",error);
    }
    return socket;
}
- (id)init {
    self = [super init];
    if (self) {
        _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return self;
}


- (void)sentMessage:(NSString *)message progress:(void(^)(float progress))progressBlock{
    NSMutableDictionary * sendDict = [[NSMutableDictionary alloc] init];
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;

    [sendDict setObject:@"text" forKey:@"MType"];
    [sendDict setObject:message forKey:@"textMessage"];
//    NSData *mData = [NSJSONSerialization dataWithJSONObject:sendDict options:NSJSONWritingPrettyPrinted error:nil];
    NSData * mData = [message dataUsingEncoding:NSUTF8StringEncoding];
    [_asyncSocket writeData:mData withTimeout:-1 tag:recordTime];

}


#pragma mark =============GCDAsyncSocket delegate=================
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"已经连接到host=%@=========port=%d",host,port);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
//    NSLog(@"%@----已经接收消息---%@",sock,_serverSocket);
//    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//    NSLog(@"%@",dict);
    
    //接收端
    
//    1.NSData 转字符串
//    NSString *s= [dict objectForKey:@"message"];
//    NSString *s=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSData *datas = [MyTools switchDataWithSexadecimalNumberString:s];
//    
//    NSString * string = [[NSString alloc] initWithData:datas encoding:NSUTF8StringEncoding];
//    
//    UIImage *i=[UIImage imageWithData:datas]//以图片为例转换后获得真正的图片
    
    
    if (data.length) {
        if (self.messageBlack) {
            self.messageBlack(data);
        }
    }
    [sock readDataWithTimeout:-1 tag:100];

}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {

//    for (MModel * modle in self.allSendMessage) {
//        if (modle.tag==tag) {
//            modle.sendProgress = 1.0;
//            [self.allSendMessage removeObject:modle];
//            break;
//        }
//    }
    NSLog(@"%@----已经发送消息---%@",sock,_asyncSocket);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err {

}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {

//    [self.socketArray addObject:newSocket];
    [newSocket readDataWithTimeout:-1 tag:100];
}



//- (NSMutableArray *)socketArray {
//    if (_socketArray==nil) {
//        _socketArray = [[NSMutableArray alloc] init];
//    }
//   return _socketArray;
//}

- (NSMutableArray *)allSendMessage {
    if (_allSendMessage==nil) {
        _allSendMessage = [[NSMutableArray alloc] init];
    }
    return _allSendMessage;
}

@end
