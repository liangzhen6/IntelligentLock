//
//  MesModel.h
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/9/10.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MesModel : NSObject
@property(nonatomic,assign)MType type;   ///< 消息类型
@property(nonatomic,copy)NSString * mes; ///< 携带的信息

@property(nonatomic,copy)NSString * lockLink; ///< 锁的链接状态
@property(nonatomic,copy)NSString * lockState; ///< 锁的状态

+ (id)mesModelType:(MType)type message:(NSString *)mes lockLink:(NSString *)lockLink lockState:(NSString *)lockState;

@end
