//
//  Tools.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/9/10.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "Tools.h"
#import <CommonCrypto/CommonCrypto.h>

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
//    NSLog(@"testByte = %d\n",testByte[i]);
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
@end
