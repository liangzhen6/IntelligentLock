//
//  MainCollectionModel.h
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/10/12.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainCollectionModel : NSObject<NSCoding>
@property(nonatomic,copy)NSString * title;
@property(nonatomic,copy)NSString * imagePath;
@property(nonatomic,copy)NSString * deviceCode;
@property(nonatomic,assign)ConnectState connectState;
@property(nonatomic,assign)CollectionModelType modelType;
+ (id)mainCollectionModelWithTitle:(NSString *)title image:(NSString *)image deviceCode:(NSString *)code modelType:(CollectionModelType)modelType;

@end
