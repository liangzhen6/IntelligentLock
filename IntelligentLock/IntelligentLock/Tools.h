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
// ase 编码
//- (NSData *)encryptData:(NSData *)rawData;
// ase 编码
- (NSData *)encryptData:(NSString *)jsonStr;

// ase 解码
- (NSData *)decryptData:(NSData *)rawData;

@end
