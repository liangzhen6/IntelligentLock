//
//  User.h
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/10/15.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property(nonatomic,strong)NSMutableArray *devicesArr;
@property(nonatomic,copy)NSString *username;
@property(nonatomic,copy)NSString *password;

+ (id)shareUser;

@end
