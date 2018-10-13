//
//  MainCollectionViewCell.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/10/12.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "MainCollectionViewCell.h"
#import "MainCollectionModel.h"

@interface MainCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIView *onlineView;
@property (weak, nonatomic) IBOutlet UILabel *onlineTitle;
@property (weak, nonatomic) IBOutlet UIImageView *connectTypeIcon;

@end

@implementation MainCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.onlineView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.onlineView.layer.borderWidth = 1;
    self.onlineView.layer.cornerRadius = 2;
}

- (void)setModel:(MainCollectionModel *)model {
    _model = model;
    _icon.image = [UIImage imageNamed:model.imagePath];
    _title.text = model.title;
    
    if (model.modelType == CollectionModelTypeAddDevice) {
        // 是增加设备的按钮 隐藏那个onlineView
        _onlineView.hidden  = YES;
    } else {
        // 是链接的设备 1.展示那个onlineView 2.把设备的链接状态展示一下
        _onlineView.hidden  = NO;
        switch (model.connectState) {
            case ConnectStateUnConnect:
                {// 离线状态
                    _onlineTitle.text = @"离线";
                    _onlineTitle.textColor = [UIColor redColor];
                    _connectTypeIcon.image = [UIImage imageNamed:@"off-line"];
                }
                break;
            case ConnectStateConnectedSocket:
                {// 网关链接
                    _onlineTitle.text = @"在线";
                    _onlineTitle.textColor = RGBColor(18.0, 150.0, 219.0);
                    _connectTypeIcon.image = [UIImage imageNamed:@"WiFi"];
                }
                break;
            case ConnectStateConnectedBluetooth:
                {// 蓝牙连接
                    _onlineTitle.text = @"在线";
                    _onlineTitle.textColor = RGBColor(18.0, 150.0, 219.0);
                    _connectTypeIcon.image = [UIImage imageNamed:@"ble"];
                }
                break;
            default:
                break;
        }

    }
    
}

@end
