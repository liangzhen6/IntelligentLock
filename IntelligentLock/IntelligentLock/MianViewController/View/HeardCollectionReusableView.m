//
//  HeardCollectionReusableView.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/10/12.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "HeardCollectionReusableView.h"
@interface HeardCollectionReusableView ()
@property (weak, nonatomic) IBOutlet UILabel *title;

@end

@implementation HeardCollectionReusableView

- (void)addTitle:(NSString *)title {
    _title.text = title;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
