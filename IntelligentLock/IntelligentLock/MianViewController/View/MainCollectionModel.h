//
//  MainCollectionModel.h
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/10/12.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainCollectionModel : NSObject
@property(nonatomic,copy)NSString * title;
@property(nonatomic,copy)NSString * imagePath;
+ (id)mainCollectionModelWithTitle:(NSString *)title image:(NSString *)image;

@end
