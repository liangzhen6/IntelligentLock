//
//  MesModel.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/9/10.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "MesModel.h"

@implementation MesModel
+ (id)mesModelType:(MType)type message:(NSString *)mes {
    MesModel * model = [[MesModel alloc] init];
    model.type = type;
    model.mes = mes;
    
    return model;
}

@end
