//
//  LoginViewController.h
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/9/29.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "RootViewController.h"
typedef void(^LoginSuccessBlock)(void);
@interface LoginViewController : RootViewController
@property(nonatomic,copy)LoginSuccessBlock successBlock;
@property(nonatomic,copy)NSString *loginTitle;
@end
