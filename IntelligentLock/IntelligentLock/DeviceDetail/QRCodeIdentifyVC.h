//
//  QRCodeIdentifyVC.h
//  QRCode
//
//  Created by shenzhenshihua on 2017/1/18.
//  Copyright © 2017年 shenzhenshihua. All rights reserved.
//

#import "RootViewController.h"
typedef void(^QRCodeIdentifyBlock)(NSString *resulrStr);

@interface QRCodeIdentifyVC : RootViewController
@property(nonatomic,copy)QRCodeIdentifyBlock identifyBlock;
@end
