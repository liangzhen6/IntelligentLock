//
//  SettModel.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/10/19.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "SettModel.h"

@implementation SettModel
+ (id)settModelWithTitle:(NSString *)title modelType:(SettModelType)modelType {
    SettModel *model = [[SettModel alloc] init];
    model.title = title;
    model.modelType = modelType;
    return model;
}
@end
