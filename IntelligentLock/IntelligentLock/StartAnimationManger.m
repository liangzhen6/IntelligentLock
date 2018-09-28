//
//  StartAnimationManger.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/9/28.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "StartAnimationManger.h"
@interface StartAnimationManger ()

@end
static StartAnimationManger * _startManger;
@implementation StartAnimationManger
+ (id)shareStartAnimationManger {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_startManger == nil) {
            _startManger = [[StartAnimationManger alloc] init];
        }
    });
    return _startManger;
}
// 启动动画
- (void)startAnimationWithBackMainView:(UIView *)backMainView startView:(UIView *)startView {
    UIView * backMainSnapView = [backMainView snapshotViewAfterScreenUpdates:YES];
    
    CGRect leftFrame = CGRectMake(0, 0, Screen_Width/2, Screen_Height);
    CGRect rightFrame = CGRectMake(Screen_Width/2, 0, Screen_Width/2, Screen_Height);
    UIView *leftStartSnapView = [startView resizableSnapshotViewFromRect:leftFrame afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
    UIView *rightStartSnapView = [startView resizableSnapshotViewFromRect:rightFrame afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
    
    UIView * containerView = [[UIView alloc] initWithFrame:Screen_Frame];
    containerView.backgroundColor = [UIColor blackColor];
    [KeyWindow addSubview:containerView];
    
    backMainSnapView.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1);
    leftStartSnapView.frame = leftFrame;
    rightStartSnapView.frame = rightFrame;
    
    [containerView addSubview:backMainSnapView];
    [containerView addSubview:leftStartSnapView];
    [containerView addSubview:rightStartSnapView];
    // 移除启动视图
    [startView removeFromSuperview];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        leftStartSnapView.frame = CGRectOffset(leftStartSnapView.frame, -Screen_Width/2, 0);
        rightStartSnapView.frame = CGRectOffset(rightStartSnapView.frame, Screen_Width/2, 0);
        backMainSnapView.layer.transform = CATransform3DIdentity;
    } completion:^(BOOL finished) {
        [leftStartSnapView removeFromSuperview];
        [rightStartSnapView removeFromSuperview];
        [backMainSnapView removeFromSuperview];
        [containerView removeFromSuperview];
    }];
    

}

@end
