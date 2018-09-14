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
// 连接状态的枚举
typedef NS_ENUM(NSUInteger, ConnectType) {
    unConnectConnectType = 0, ///< 未连接状态
    connectingConnectType,    ///< 正在连接中
    connectedConnectType      ///< 已经连接了
};

#endif /* EnumHeader_h */
