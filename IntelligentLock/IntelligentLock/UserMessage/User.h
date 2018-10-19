//
//  User.h
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/10/15.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject<NSCoding>
@property(nonatomic,strong)NSMutableArray *devicesArr;
@property(nonatomic,copy)NSString *username; ///< 用户名（邮箱）
@property(nonatomic,copy)NSString *password; ///< 密码
@property(nonatomic,copy)NSString *userIcon; ///< 用户头像
@property(nonatomic,assign)BOOL loginState;  ///< 是否是登录状态

@property(nonatomic,assign)BOOL closeAllDevice; ///< 禁用所有设备
@property(nonatomic,assign)BOOL fingerprintLogin; ///< 指纹登录
+ (id)shareUser;

- (BOOL)writeUserMesage;

- (id)readUserMesage;
@end
