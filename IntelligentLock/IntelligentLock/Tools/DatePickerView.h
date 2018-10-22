//
//  DatePickerView.h
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/10/22.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^DatePickerResultBlock)(NSString *selectTime);
@interface DatePickerView : UIView
- (id)initWithFrame:(CGRect)frame pickerResult:(DatePickerResultBlock)pickerResult;

@end
