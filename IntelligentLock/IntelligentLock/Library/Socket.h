//
//  Socket.h
//  SocketTest
//
//  Created by shenzhenshihua on 2017/2/24.
//  Copyright © 2017年 shenzhenshihua. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MesModel;
typedef void(^SocketConnectStateBlock)(SocketConnectState connectState);
@interface Socket : NSObject
@property(nonatomic,copy)void(^messageBlack)(NSDictionary *message);
@property(nonatomic,copy)void(^progressBlock)(float progress);

@property(nonatomic,assign)SocketConnectState socketConnectState;
@property(nonatomic,assign)BOOL canConnect;
+ (id)shareSocket;
// 初始化链接
+ (id)shareSocketWithHost:(NSString *)host port:(int)port messageBlack:(void(^)(NSDictionary *message))messageBlack;
// 初始化 设置端口等信息
+ (id)shareSocketWithHost:(NSString *)host port:(int)port;
//发送消息
- (void)sentMessage:(MesModel *)model progress:(void(^)(float progress))progressBlock;
//连接服务器
- (void)connectServer;

/**
 连接服务器 返回链接状态
 */
- (void)connectServerWithCompletion:(SocketConnectStateBlock)connectBlock;
/**
 断开连接
 */
- (void)closeConnectServer;

@end
