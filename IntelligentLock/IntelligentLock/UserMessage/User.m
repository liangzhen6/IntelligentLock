//
//  User.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/10/15.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "User.h"
#import "Tools.h"
@interface User ()

@end
static User * _user = nil;
@implementation User
+ (id)shareUser {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_user == nil) {
            _user = [[User alloc] init];
//            _user.username = @"liangzhen@163.com";
//            _user.password = @"liangzhen";
        }
    });
    return _user;
}

#pragma mark --NSCoding
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _username = [aDecoder decodeObjectForKey:@"username"];
        _password = [aDecoder decodeObjectForKey:@"password"];
        _userIcon = [aDecoder decodeObjectForKey:@"userIcon"];
        _loginState = [aDecoder decodeBoolForKey:@"loginState"];
        _closeAllDevice = [aDecoder decodeBoolForKey:@"closeAllDevice"];
        _fingerprintLogin = [aDecoder decodeBoolForKey:@"fingerprintLogin"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_username forKey:@"username"];
    [aCoder encodeObject:_password forKey:@"password"];
    [aCoder encodeObject:_userIcon forKey:@"userIcon"];
    [aCoder encodeBool:_loginState forKey:@"loginState"];
    [aCoder encodeBool:_closeAllDevice forKey:@"closeAllDevice"];
    [aCoder encodeBool:_fingerprintLogin forKey:@"fingerprintLogin"];
}

- (BOOL)writeUserMesage {
    return [[Tools shareTools] writeID:_user pathString:User_Data_Key];
}

- (id)readUserMesage {
    if ([[Tools shareTools] readWithPathString:User_Data_Key]) {
        _user = [[Tools shareTools] readWithPathString:User_Data_Key];
    }
    return _user;
}

- (NSMutableArray *)devicesArr {
    if (_devicesArr == nil) {
        _devicesArr = [[NSMutableArray alloc] init];
    }
    return _devicesArr;
}
@end
