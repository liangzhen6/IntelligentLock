//
//  StartAnimationManger.h
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/9/28.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface StartAnimationManger : NSObject
+ (id)shareStartAnimationManger;
- (void)startAnimationWithBackMainView:(UIView *)backMainView startView:(UIView *)startView;
@end
