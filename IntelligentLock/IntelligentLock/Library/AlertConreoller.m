//
//  AlertConreoller.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/9/26.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "AlertConreoller.h"

@implementation AlertConreoller

+ (void)alertControllerWithController:(UIViewController *)controller title:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle cancelAction:(void(^)(void))cancelAction otherAction:(void(^)(void))otherAction {
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (cancelButtonTitle.length) {
        UIAlertAction * cancle = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (cancelAction) {
                cancelAction();
            }
        }];
        [alertController addAction:cancle];
    }
    
    if (otherButtonTitle.length && otherAction) {
        UIAlertAction * other = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (otherAction) {
                otherAction();
            }
        }];
        [alertController addAction:other];
    }
    if (controller) {
        [controller presentViewController:alertController animated:YES completion:nil];
    } else{
        [KeyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    }
}

@end
