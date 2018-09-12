//
//  MesModel.h
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/9/10.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MType) {
    heartMType = 0, ///< 心跳包
    commandMType    ///< 指令
};

@interface MesModel : NSObject
@property(nonatomic,assign)MType type;   ///< 消息类型
@property(nonatomic,copy)NSString * mes; ///< 携带的信息

+ (id)mesModelType:(MType)type message:(NSString *)mes;

@end
