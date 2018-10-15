//
//  Tools.h
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/9/10.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tools : NSObject
+ (id)shareTools;
/**
 获取一个路径
 
 @param key 路径的key
 @return 返回path
 */
+ (NSString *)returnThePath:(NSString *)key;
/**
 本地化读取操作
 
 @param key key description
 @return return 读取的值
 */
+ (id)readWithPathString:(NSString *)key;

/**
 本地化写入操作
 
 @param object 写入一个对象
 @param key key description
 @return 是否写入成功
 */
+ (BOOL)writeID:(id)object pathString:(NSString *)key;

// ase 编码
//- (NSData *)encryptData:(NSData *)rawData;
// ase 编码
- (NSData *)encryptData:(NSString *)jsonStr;

// ase 解码
- (NSData *)decryptData:(NSData *)rawData;

// 将字符串转化为Hex(16进制) NSData
- (NSData *)convertHexStrToData:(NSString *)str;

/**
 检查设备指纹是否可用？

 @return 返回 错误信息，error = nil 指纹可用
 */
- (NSError *)chickTouchIdCanUse;

/**
 验证指纹的方法， 内部会先调用 chickTouchIdCanUse

 @param result 校验的结果
 @param reply 用户点了 取消 或者用账户密码登录
 */
- (void)verbTouchIdResult:(void(^)(BOOL success, NSError *error))result replyAction:(void(^)(TouchIdReply reply))reply;

@end
