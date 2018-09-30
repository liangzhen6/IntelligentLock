//
//  MesModel.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/9/10.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "MesModel.h"

@implementation MesModel
+ (id)mesModelType:(MType)type message:(NSString *)mes lockLink:(NSString *)lockLink lockState:(NSString *)lockState {
    MesModel * model = [[MesModel alloc] init];
    model.type = type;
    model.mes = mes;
    if ([lockLink length]) {
        model.lockLink = lockLink;
    }
    if ([lockState length]) {
        model.lockState = lockState;
    }
    
    return model;
}

@end
