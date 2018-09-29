//
//  StartView.h
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/9/28.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^StartBtnBlock)(StartBtnActionType btnActionType);
@interface StartView : UIView
@property(nonatomic,copy)StartBtnBlock startBtnBlock;
+ (id)shareStartView;
- (void)setStartRevolve:(BOOL)revolve;
- (void)alertTitle:(NSString *)title;
@end
