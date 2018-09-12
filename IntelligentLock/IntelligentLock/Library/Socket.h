//
//  Socket.h
//  SocketTest
//
//  Created by shenzhenshihua on 2017/2/24.
//  Copyright © 2017年 shenzhenshihua. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MesModel;
@interface Socket : NSObject
@property(nonatomic,copy)void(^messageBlack)(NSString *message);
@property(nonatomic,copy)void(^progressBlock)(float progress);

@property(nonatomic,assign)ConnectType socketConnectType;
@property(nonatomic,assign)BOOL appIsAction;
+ (id)shareSocket;
// 初始化链接
+ (id)shareSocketWithHost:(NSString *)host port:(int)port messageBlack:(void(^)(NSString *message))messageBlack;
//发送消息
- (void)sentMessage:(MesModel *)model progress:(void(^)(float progress))progressBlock;
//连接服务器
- (void)connectServer;
//断开连接
- (void)closeConnectServer;

@end
