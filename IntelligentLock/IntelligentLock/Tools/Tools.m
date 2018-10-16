//
//  Tools.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/9/10.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "Tools.h"
#import <CommonCrypto/CommonCrypto.h>
#import <LocalAuthentication/LocalAuthentication.h>

@interface Tools ()

@end
static Tools * _tools = nil;
static NSString const * key = @"ADER19T22H2K56U5";
@implementation Tools
+ (id)shareTools {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_tools == nil) {
            _tools = [[Tools alloc] init];
        }
    });
    return _tools;
}

- (NSString *)returnThePath:(NSString *)key {
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    NSString * path = [documentsDirectory stringByAppendingPathComponent:key];
    return path;
    
}

- (id)readWithPathString:(NSString *)key {
    NSString * path = [self returnThePath:key];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}

- (BOOL)writeID:(id)object pathString:(NSString *)key {
    NSString * path = [self returnThePath:key];
    return [NSKeyedArchiver archiveRootObject:object toFile:path];
}

- (NSData *)encryptData:(NSString *)jsonStr {
    char keyPtr[kCCKeySizeAES128+1];
    //    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSInteger jsonStrLength = [jsonStr length];
    NSData *ivDecodedData = [key dataUsingEncoding:NSUTF8StringEncoding];

    
    NSInteger diff = kCCKeySizeAES128 - (jsonStrLength % kCCKeySizeAES128);
    jsonStrLength += diff;
    NSMutableString * jsonStrM = [[NSMutableString alloc] initWithString:jsonStr];
    for (NSInteger i = 0; i < diff; i++) {
        [jsonStrM appendString:@"\0"];
    }
    
    NSData * rawData = [jsonStrM dataUsingEncoding:NSUTF8StringEncoding];
    
    char dataPtr[jsonStrLength];
    memcpy(dataPtr, [rawData bytes], [rawData length]);
    size_t bufferSize = jsonStrLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    
    size_t numBytesCrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,              //No padding
                                          keyPtr,
                                          kCCKeySizeAES128,
                                          [ivDecodedData bytes],
                                          [rawData bytes],
                                          [rawData length],
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        NSString *base64String= [resultData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        return [base64String dataUsingEncoding:NSUTF8StringEncoding];
    }
    free(buffer);    
    return nil;
}
/*
- (NSData *)encryptData:(NSData *)rawData {
    char keyPtr[kCCKeySizeAES128+1];
//    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

//    char ivPtr[kCCBlockSizeAES128+1];
//    memset(ivPtr, 0, sizeof(ivPtr));
//    [key getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];

//    NSData* data = [plainText dataUsingEncoding:NSUTF8StringEncoding];

    NSData *ivDecodedData = [key dataUsingEncoding:NSUTF8StringEncoding];

    int dataLength = (int)[rawData length];


    int diff = kCCKeySizeAES128 - (dataLength % kCCKeySizeAES128);
    int newSize = 0;
    newSize = dataLength + diff;

//    if(diff > 0)
//    {
//        newSize = dataLength + diff;
//    }
//
    char dataPtr[newSize];
    memcpy(dataPtr, [rawData bytes], [rawData length]);
    for(int i = 0; i < diff; i++)
    {
        dataPtr[i + dataLength] = 0x00;
    }
//
//    char dataPtr[dataLength];
//    memcpy(dataPtr, [rawData bytes], [rawData length]);

    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
//    memset(buffer, 0, bufferSize);

    size_t numBytesCrypted = 0;

    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,              //No padding
                                          keyPtr,
                                          kCCKeySizeAES128,
                                          [ivDecodedData bytes],
                                          dataPtr,
                                          sizeof(dataPtr),
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);

    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        NSString *base64String= [resultData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        return [base64String dataUsingEncoding:NSUTF8StringEncoding];
    }
    free(buffer);
    return nil;
}
*/
- (NSData *)decryptData:(NSData *)rawData {
    //先把 原始数据 从base64 字符串转成 AES data
    NSString * base64Str = [[NSString alloc] initWithData:rawData encoding:NSUTF8StringEncoding];
    rawData = [[NSData alloc] initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    // 接下里 处理 AES Data 解密
    char keyPtr[kCCKeySizeAES128+1];
    //AES iv向量必须先Base64 decode一下,和后台保持一致（实际使用中要看后台如何处理）
    NSData *ivDecodedData = [key dataUsingEncoding:NSUTF8StringEncoding];
//    Byte *testByte = (Byte *)[ivDecodedData bytes];
//    
//    for(int i=0;i<[ivDecodedData length];i++)
//    MPNLog(@"testByte = %d\n",testByte[i]);
//    
 
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:kCCKeySizeAES128+1 encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [rawData length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr, strlen(keyPtr),
                                          [ivDecodedData bytes],
                                          [rawData bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted
                                          );
    if (cryptStatus == kCCSuccess) {
        NSData * deAESData = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        // 将数据转换成 jsonData
        NSString * jsonStr = [[NSString alloc] initWithData:deAESData encoding:NSUTF8StringEncoding];
        //先把后面补的 \0 去除
        jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\0" withString:@""];
        return [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    }
    free(buffer);
    return nil;
}

/* 将字符串转化为Hex(16进制) NSData */
- (NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] init];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

- (NSError *)chickTouchIdCanUse {
    NSError * error = nil; // 默认为 nil 是可用
    LAContext * context = [[LAContext alloc] init];
    /*
     LAPolicyDeviceOwnerAuthenticationWithBiometrics  > ios 8.0只能通过指纹验证才能成功（常用 推荐）
     LAPolicyDeviceOwnerAuthentication >ios 9.0 这种方式用户可以指纹验证或者输入密码。（会让用户与本来的账号密码混淆）
     */
    if (![context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        // 存在错误
        MPNLog(@"%@",error);
        switch (error.code) {
            case LAErrorTouchIDNotEnrolled:
                {// 没有设置Touch Id
                    error = [[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:-1002 userInfo:@{NSLocalizedDescriptionKey:@"用户没有设置ID", NSUnderlyingErrorKey:@"请先去设置页面开通指纹"}];
                }
                break;
            case LAErrorPasscodeNotSet:
                {// 没有设置 密码
                    error = [[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:-1003 userInfo:@{NSLocalizedDescriptionKey:@"用户没有设置解锁密码", NSUnderlyingErrorKey:@"请先去设置页面设置解锁密码"}];
                }
                break;
            case LAErrorTouchIDLockout:
                {// 多次验证失败被锁 ID
                    error = [[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:-1004 userInfo:@{NSLocalizedDescriptionKey:@"多次授权失败", NSUnderlyingErrorKey:@"指纹多次输入错误，请稍后再试"}];
                }
                break;
            default:
                { // 其他 都算是不支持指纹
                 error = [[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:-1001 userInfo:@{NSLocalizedDescriptionKey:@"设备不支持", NSUnderlyingErrorKey:@"你的设备暂不支持指纹！"}];
                }
                break;
        }
    }
    
    return error;
}

- (void)verbTouchIdResult:(void(^)(BOOL success, NSError *error))result replyAction:(void(^)(TouchIdReply reply))reply {
    NSError * chickError = [self chickTouchIdCanUse];
    
    if (chickError) {
        // 直接检查不通过
        if (result) {
            result(NO, chickError);
        }
    } else {
        LAContext * context = [[LAContext alloc] init];
        NSString * reasion = @"通过Home键验证已有手机指纹";
        
        context.localizedFallbackTitle = @"密码登录";
        context.localizedCancelTitle = @"取消";
        
        // 检查通过，下面开始验证
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reasion reply:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                if (result) {
                    result(YES, nil);
                }
            } else {
                switch (error.code) {
                    case LAErrorUserCancel:
                        {// 用户取消了验证
                            NSError * resultError = [[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:-1009 userInfo:@{NSLocalizedDescriptionKey:@"用户点击了取消", NSUnderlyingErrorKey:@"你取消了指纹验证"}];
                            if (result) {
                                result(NO, resultError);
                            }
                            if (reply) {
                                reply(TouchIdReplyCancel);
                            }
                        }
                        break;
                    case LAErrorAuthenticationFailed:
                        {// 用户验证失败
                         NSError * resultError = [[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:-1005 userInfo:@{NSLocalizedDescriptionKey:@"用户验证失败", NSUnderlyingErrorKey:@"指纹验证失败，请稍后再试"}];
                            if (result) {
                                result(NO, resultError);
                            }
                        }
                        break;
                    case LAErrorUserFallback:
                        {// 用户身份验证被取消，因为用户点击了后退按钮(输入密码)
                            NSError * resultError = [[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:-1010 userInfo:@{NSLocalizedDescriptionKey:@"用户选择账号密码登录", NSUnderlyingErrorKey:@"你将使用账号密码登录"}];
                            if (result) {
                                result(NO, resultError);
                            }
                            if (reply) {
                                reply(TouchIdReplyPasswordLogin);
                            }
                        }
                        break;
                    case LAErrorTouchIDLockout:
                        {// 如果多次输入错误的指纹，验证授权会被锁定，这个时候需要用户锁定手机屏幕后，再次进入手机输入密码才能解锁。
                            NSError * resultError = [[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:-1004 userInfo:@{NSLocalizedDescriptionKey:@"多次授权失败", NSUnderlyingErrorKey:@"指纹多次输入错误，请稍后再试"}];
                            if (result) {
                                result(NO, resultError);
                            }
                        }
                        break;
                    default:
                        break;
                }
            }
        }];
    }
}

@end
