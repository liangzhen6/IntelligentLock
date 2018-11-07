
//
//  MPShare.m
//  MingPaoNews
//
//  Created by shenzhenshihua on 2017/9/29.
//  Copyright © 2017年 United Network Services Ltd. of Shenzhen City. All rights reserved.
//

#import "MPShare.h"
#import <SVProgressHUD.h>

@implementation MPShare

+ (void)shareWithText:(NSString *)textToShare image:(UIImage *)imageToshare url:(NSURL *)urlToShare rootViewController:(UIViewController *)rootVC {
    NSMutableArray *activityItems = [[NSMutableArray alloc] init];
    if (textToShare) {
        [activityItems addObject:textToShare];
    }
    if (imageToshare) {
        [activityItems addObject:imageToshare];
    }
    if (urlToShare) {
        [activityItems addObject:urlToShare];
    }
    
    if (!activityItems.count) {
        return;
    }
    
    UIActivityViewController *activeVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [activeVC setCompletionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        if (activityError) {
            [SVProgressHUD showErrorWithStatus:@"分享失敗!"];
            [SVProgressHUD dismissWithDelay:1.5];
            MPNLog(@"%@",activityError);
        }
    }];
    
    if (rootVC) {
        [rootVC presentViewController:activeVC animated:YES completion:nil];
    } else {
        [KeyWindow.rootViewController presentViewController:activeVC animated:YES completion:nil];
    }
}

@end
