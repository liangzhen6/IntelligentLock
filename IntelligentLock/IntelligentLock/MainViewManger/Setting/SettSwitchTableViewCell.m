//
//  SettSwitchTableViewCell.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/10/19.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "SettSwitchTableViewCell.h"
#import "SettModel.h"
@interface SettSwitchTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *title;

@end

@implementation SettSwitchTableViewCell
- (void)setModel:(SettModel *)model {
    _model = model;
    _title.text = model.title;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Initialization code
}
- (IBAction)switchBtnAction:(UISwitch *)sender {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
