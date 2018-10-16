//
//  User.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/10/15.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "User.h"
@interface User ()

@end
static User * _user = nil;
@implementation User
+ (id)shareUser {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_user == nil) {
            _user = [[User alloc] init];
        }
    });
    return _user;
}

- (NSMutableArray *)devicesArr {
    if (_devicesArr == nil) {
        _devicesArr = [[NSMutableArray alloc] init];
    }
    return _devicesArr;
}
@end
