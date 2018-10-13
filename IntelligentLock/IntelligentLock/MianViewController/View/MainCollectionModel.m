//
//  MainCollectionModel.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/10/12.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "MainCollectionModel.h"

@implementation MainCollectionModel
+ (id)mainCollectionModelWithTitle:(NSString *)title image:(NSString *)image modelType:(CollectionModelType)modelType {
    MainCollectionModel *model = [[MainCollectionModel alloc] init];
    model.title = title;
    model.imagePath = image;
    model.modelType = modelType;
    return model;
}
@end
