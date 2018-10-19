//
//  SettModel.h
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/10/19.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettModel : NSObject
@property(nonatomic,copy)NSString * title;
@property(nonatomic,assign)SettModelType modelType;
+ (id)settModelWithTitle:(NSString *)title modelType:(SettModelType)modelType;

@end
