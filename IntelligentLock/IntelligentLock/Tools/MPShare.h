//
//  MPShare.h
//  MingPaoNews
//
//  Created by shenzhenshihua on 2017/9/29.
//  Copyright © 2017年 United Network Services Ltd. of Shenzhen City. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPShare : NSObject

/**
 调用系统分享的方法

 @param textToShare 分享的文字   如果没有传nil
 @param imageToshare 分享的图片 如果没有传nil
 @param urlToShare 分享的链接   如果没有传nil
 */
+ (void)shareWithText:(NSString *)textToShare image:(UIImage *)imageToshare url:(NSURL *)urlToShare rootViewController:(UIViewController *)rootVC;

@end
