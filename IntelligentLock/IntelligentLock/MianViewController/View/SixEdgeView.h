//
//  SixEdgeView.h
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/10/12.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SixEdgeView : UIView
- (id)initWithFrame:(CGRect)frame;
- (void)startAnimation;
- (void)endAnimation;
- (void)updateDeviceNumber:(NSString *)deviceNumberStr;

@end
