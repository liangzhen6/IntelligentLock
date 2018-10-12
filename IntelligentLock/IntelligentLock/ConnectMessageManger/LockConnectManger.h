//
//  LockConnectManger.h
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/9/26.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^LockStateBlock)(ConnectState connectState, BluetoothLockState lockState);
@interface LockConnectManger : NSObject
@property(nonatomic,assign)BOOL appIsAction; ///< App是否处理活跃状态
@property(nonatomic,assign)ConnectState connectState; ///< 链接的状态
@property(nonatomic,assign)BOOL lockMangerCanConnect;
@property(nonatomic,copy)LockStateBlock lockStateBlock;
@property(nonatomic,assign)NetWorkState netWorkState;

+ (id)shareLockConnectManger;

/**
 监控网络状态
 */
- (void)observeReachabilityStatus;

/**
 App 将要挂起
 */
- (void)willResignActive;

/**
 App 已经处理活跃状态
 */
- (void)didBecomeActive;

/**
 开始发起 链接
 */
- (void)connect;

/**
 关闭 连接
 */
- (void)closeConnect;

/**
 开门操作
 */
- (void)openLock;
@end
