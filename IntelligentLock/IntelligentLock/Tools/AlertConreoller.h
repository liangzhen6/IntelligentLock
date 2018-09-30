//
//  AlertConreoller.h
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/9/26.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AlertConreoller : NSObject

+ (void)alertControllerWithController:(UIViewController *)controller title:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle cancelAction:(void(^)(void))cancelAction otherAction:(void(^)(void))otherAction;

@end
