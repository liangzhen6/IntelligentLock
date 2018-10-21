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
@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;

@end

@implementation SettSwitchTableViewCell
- (void)setModel:(SettModel *)model {
    _model = model;
    _title.text = model.title;
    if (model.loginState) {
        _title.textColor = [UIColor whiteColor];
        _switchBtn.on = model.switchOn;
    } else {
        _title.textColor = [UIColor grayColor];
        _switchBtn.on = NO;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Initialization code
}
- (IBAction)switchBtnAction:(UISwitch *)sender {
    if (self.model.loginState) {
        // 已经登录
        if (self.model.modelType == SettModelTypeCloseAllDeviceSwitch) {
            self.model.switchOn = sender.on;
        } else {
            sender.on = self.model.switchOn;
        }
        if (self.switchBtnBlock) {
            self.switchBtnBlock(self.model);
        }
    } else {
        // 没有登录
        sender.on = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
