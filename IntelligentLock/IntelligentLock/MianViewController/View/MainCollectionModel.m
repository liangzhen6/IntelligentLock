//
//  MainCollectionModel.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/10/12.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "MainCollectionModel.h"

@implementation MainCollectionModel
+ (id)mainCollectionModelWithTitle:(NSString *)title image:(NSString *)image deviceCode:(NSString *)code expiredTime:(NSString *)expiredTime bunAllDevice:(BOOL)isBun modelType:(CollectionModelType)modelType {
    MainCollectionModel *model = [[MainCollectionModel alloc] init];
    model.title = title;
    model.imagePath = image;
    model.deviceCode = code;
    model.expiredTime = expiredTime;
    model.bunAllDevice = isBun;
    model.modelType = modelType;
    return model;
}

#pragma mark --NSCoding
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _title = [aDecoder decodeObjectForKey:@"title"];
        _imagePath = [aDecoder decodeObjectForKey:@"imagePath"];
        _deviceCode = [aDecoder decodeObjectForKey:@"deviceCode"];
        _expiredTime = [aDecoder decodeObjectForKey:@"expiredTime"];
        _bunAllDevice = [aDecoder decodeBoolForKey:@"bunAllDevice"];
        _modelType = [aDecoder decodeIntegerForKey:@"modelType"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_imagePath forKey:@"imagePath"];
    [aCoder encodeObject:_deviceCode forKey:@"deviceCode"];
    [aCoder encodeObject:_expiredTime forKey:@"expiredTime"];
    [aCoder encodeBool:_bunAllDevice forKey:@"bunAllDevice"];
    [aCoder encodeInteger:_modelType forKey:@"modelType"];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"--%@--%@--%@-%lu--%@--%d--",_title,_imagePath,_deviceCode,(unsigned long)_modelType,_expiredTime,_bunAllDevice];
}
@end
