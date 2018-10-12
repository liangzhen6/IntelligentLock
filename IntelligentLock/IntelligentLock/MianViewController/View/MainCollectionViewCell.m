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

@end

@implementation MainCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

}

- (void)setModel:(MainCollectionModel *)model {
    _model = model;
    _icon.image = [UIImage imageNamed:model.imagePath];
    _title.text = model.title;
//    
//    self.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.layer.shadowRadius = 5.0;
//    self.layer.shadowOpacity = 0.5;
    
}

@end
