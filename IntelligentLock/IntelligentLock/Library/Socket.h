//
//  Socket.h
//  SocketTest
//
//  Created by shenzhenshihua on 2017/2/24.
//  Copyright © 2017年 shenzhenshihua. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface Socket : NSObject

@property(nonatomic,copy)void(^messageBlack)(NSData *message);
@property(nonatomic,copy)void(^progressBlock)(float progress);

@property(nonatomic,assign)BOOL isConnect;
+ (id)shareSocket;

+ (id)shareSocketWithHost:(NSString *)host port:(int)port messageBlack:(void(^)(NSData *message))messageBlack;


- (void)sentMessage:(NSString *)message progress:(void(^)(float progress))progressBlock;

@end
