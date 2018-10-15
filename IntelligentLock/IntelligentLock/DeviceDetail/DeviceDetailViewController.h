//
//  DeviceDetailViewController.h
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/10/13.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "RootViewController.h"
@class MainCollectionModel;
typedef void(^DeviceBlock)(DeviceBackType backType, MainCollectionModel *model);

@interface DeviceDetailViewController : RootViewController
@property(nonatomic,strong)MainCollectionModel *deviceModel;
@property(nonatomic,copy)DeviceBlock deviceBlock;

@end
