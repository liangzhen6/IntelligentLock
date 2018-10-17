//
//  HeaderUnNetWorkCollectionReusableView.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/10/17.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "HeaderUnNetWorkCollectionReusableView.h"
@interface HeaderUnNetWorkCollectionReusableView ()
@property (weak, nonatomic) IBOutlet UILabel *title;

@end
@implementation HeaderUnNetWorkCollectionReusableView
- (void)addTitle:(NSString *)title {
    _title.text = title;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
