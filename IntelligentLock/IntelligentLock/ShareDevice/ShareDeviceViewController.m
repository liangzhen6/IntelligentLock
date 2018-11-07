//
//  ShareDeviceViewController.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/10/22.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "ShareDeviceViewController.h"
#import "DatePickerView.h"
#import "QRCodeTool.h"
#import "MPShare.h"
#import "Tools.h"
#import "MainCollectionModel.h"
#import <SVProgressHUD.h>

@interface ShareDeviceViewController ()
@property(nonatomic,copy)NSString * timeStr;

@end

@implementation ShareDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    // Do any additional setup after loading the view from its nib.
}

- (void)initView {
    self.view.backgroundColor = RGBColor(245.0, 244.0, 245.0);
    self.title = @"分享设备";
    
    UILabel * timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 250, Screen_Width-30, 30)];
    [self.view addSubview:timeLabel];
    __weak typeof (self)ws = self;
    DatePickerView * pickerView = [[DatePickerView alloc] initWithFrame:CGRectMake(15, 50, Screen_Width-30, 180) pickerResult:^(NSString *selectTime) {
        // 选中的日期
        MPNLog(@"%@",selectTime);
        ws.timeStr = selectTime;
        timeLabel.text = [NSString stringWithFormat:@"使用截止：%@", selectTime];
    }];
    [self.view addSubview:pickerView];
    
    UIButton * shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(timeLabel.frame)+20, Screen_Width-30, 50)];
    shareBtn.backgroundColor = RGBColor(212.0, 162.0, 44.0);
    shareBtn.layer.cornerRadius = 10;
    [shareBtn setTitle:@"分享" forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareBtn];
}

- (void)shareBtnAction:(UIButton *)btn {
  // 将设备的Id 加密处理
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    NSDate * selectTime = [formatter dateFromString:self.timeStr];
    NSDate * currentDate = [formatter dateFromString:[formatter stringFromDate:[NSDate date]]];
    NSComparisonResult result = [selectTime compare:currentDate];
    if (result == NSOrderedAscending) {
        // 已经过期
        [SVProgressHUD showErrorWithStatus:@"当前日期不可用，请重新选择！"];
        [SVProgressHUD dismissWithDelay:1.5];
    } else {
        NSDictionary * dict = @{@"expiredTime":self.timeStr, @"deviceCode":self.deviceModel.deviceCode};
        NSData *mData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        NSString * jsonStr = [[NSString alloc] initWithData:mData encoding:NSUTF8StringEncoding];
        
        NSData * enCodeData = [[Tools shareTools] encryptData:jsonStr];
        NSString * enCodeStr = [[NSString alloc] initWithData:enCodeData encoding:NSUTF8StringEncoding];
        
        UIImage *qrCodeImage = [QRCodeTool createDefaultQRCodeWithData:enCodeStr imageViewSize:CGSizeMake(Screen_Width, Screen_Width)];
        [MPShare shareWithText:@"门禁二维码，请不要转发他人。" image:qrCodeImage url:nil rootViewController:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
