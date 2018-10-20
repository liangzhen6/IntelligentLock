//
//  SettTableViewCell.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/10/19.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "SettTableViewCell.h"
#import "SettModel.h"
@interface SettTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *title;

@end
@implementation SettTableViewCell

- (void)setModel:(SettModel *)model {
    _model = model;
    _title.text = model.title;
    if (model.loginState) {
        _title.textColor = [UIColor whiteColor];
    } else {
        _title.textColor = [UIColor grayColor];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
