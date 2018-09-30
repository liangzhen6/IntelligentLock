//
//  MangerViewController.h
//  LeftMenuDemo
//
//  Created by shenzhenshihua on 2018/9/28.
//  Copyright © 2018年 shenzhenshihua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MangerViewController : UIViewController
+ (id)shareMangerViewController;
- (void)setLeftViewController:(UIViewController *)leftVC mainViewController:(UIViewController *)mainVC;
- (void)showLeftViewAnimate:(BOOL)animate duration:(NSTimeInterval)duration;
- (void)dismissLeftViewAnimate:(BOOL)animate duration:(NSTimeInterval)duration;
- (void)mainOpenLeftViewHidden:(BOOL)hidden;

@end
