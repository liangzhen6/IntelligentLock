//
//  MainCollectionModel.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/10/12.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "MainCollectionModel.h"

@implementation MainCollectionModel
+ (id)mainCollectionModelWithTitle:(NSString *)title image:(NSString *)image deviceCode:(NSString *)code modelType:(CollectionModelType)modelType {
    MainCollectionModel *model = [[MainCollectionModel alloc] init];
    model.title = title;
    model.imagePath = image;
    model.modelType = modelType;
    model.deviceCode = code;
    return model;
}

#pragma mark --NSCoding
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _title = [aDecoder decodeObjectForKey:@"title"];
        _imagePath = [aDecoder decodeObjectForKey:@"imagePath"];
        _deviceCode = [aDecoder decodeObjectForKey:@"deviceCode"];
        _modelType = [aDecoder decodeIntegerForKey:@"modelType"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_imagePath forKey:@"imagePath"];
    [aCoder encodeObject:_deviceCode forKey:@"deviceCode"];
    [aCoder encodeInteger:_modelType forKey:@"modelType"];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"--%@--%@--%@-%lu-",_title,_imagePath,_deviceCode,(unsigned long)_modelType];
}
@end
