//
//  EnumHeader.h
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/9/12.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#ifndef EnumHeader_h
#define EnumHeader_h
#import <Foundation/Foundation.h>

// lcok connect manger 的链接状态
typedef NS_ENUM(NSUInteger, ConnectState) {
    ConnectStateUnConnect = 0,       ///< 未连接状态
    ConnectStateConnectedSocket,     ///< socket 链接状态
    ConnectStateConnectedBluetooth,  ///< 蓝牙 连接状态
};

// lock 当前的状态
typedef NS_ENUM(NSUInteger, LockState) {
    LockStateLock = 0,  ///< 关闭状态
    LockStateUnLock,       ///< 开启状态
};

// socket 连接下 lock 的状态
typedef NS_ENUM(NSUInteger, SocketLockState) {
    SocketLockStateLock = 0,  ///< 关闭状态
    SocketLockStateUnLock,    ///< 开启状态
};

// socket 连接状态的枚举
typedef NS_ENUM(NSUInteger, SocketConnectState) {
    SocketConnectStateUnConnect = 0, ///< 未连接状态
    SocketConnectStateConnecting,    ///< 正在连接中
    SocketConnectStateConnected,     ///< 已经连接了
};

// 蓝牙锁的状态
typedef NS_ENUM(NSUInteger, BluetoothLockState) {
    BluetoothLockStateLock = 0, ///< 关闭状态
    BluetoothLockStateUnLock,   ///< 开启状态
};

// 蓝牙的连接状态
typedef NS_ENUM(NSUInteger, BluetoothLockLinkState) {
    BluetoothLockLinkStateOff = 0, ///< 处于断开状态 （包含不可用）
    BluetoothLockLinkStateOn,      ///< 处理链接状态
};

// 消息的类型
typedef NS_ENUM(NSUInteger, MType) {
    heartMType = 0, ///< 心跳包
    commandMType,   ///< 指令
};

// 用户使用touch ID 触发的事件
typedef NS_ENUM(NSUInteger, TouchIdReply) {
    TouchIdReplyCancel = 0, ///< 用户点了取消
    TouchIdReplyPasswordLogin, ///< 用户点了使用密码登录
};

// startbtn 的事件类型
typedef NS_ENUM(NSUInteger, StartBtnActionType) {
    StartBtnActionTypeTap = 0,  ///< 点击事件
    StartBtnActionTypeLongPress, ///< 长按事件
};

#endif /* EnumHeader_h */
