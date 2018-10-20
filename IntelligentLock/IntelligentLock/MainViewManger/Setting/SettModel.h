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
@property(nonatomic,assign)BOOL loginState;
@property(nonatomic,assign)BOOL switchOn;
+ (id)settModelWithTitle:(NSString *)title modelType:(SettModelType)modelType loginState:(BOOL)loginState switchOn:(BOOL)switchOn;

@end
