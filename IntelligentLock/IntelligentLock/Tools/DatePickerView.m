//
//  DatePickerView.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/10/22.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "DatePickerView.h"
@interface DatePickerView ()<UIPickerViewDataSource,UIPickerViewDelegate>
@property(nonatomic,strong)UIPickerView * pickerView;

@property(nonatomic,strong)NSMutableArray * yearsData;
@property(nonatomic,strong)NSMutableArray * monthsData;
@property(nonatomic,strong)NSMutableArray * daysData;
@property(nonatomic,strong)NSMutableArray * hoursData;
@property(nonatomic,strong)NSMutableArray * minutesData;

@property(nonatomic,copy)DatePickerResultBlock pickerResultBlock;

@end

@implementation DatePickerView
- (id)initWithFrame:(CGRect)frame pickerResult:(DatePickerResultBlock)pickerResult {
    self = [super initWithFrame:frame];
    if (self) {
        self.pickerResultBlock = pickerResult;
        [self initView];
        [self initData];
    }
    return self;
}

- (void)initData {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone localTimeZone]];
    
    NSDate *nextDay = [NSDate dateWithTimeInterval:24*60*60 sinceDate:[NSDate date]];
    NSRange daysInOfMonth = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:nextDay];
    
    self.yearsData = [NSMutableArray array];
    self.monthsData = [NSMutableArray array];
    self.daysData = [NSMutableArray array];
    self.hoursData = [NSMutableArray array];
    self.minutesData = [NSMutableArray array];

    for (NSInteger i = 1900; i < 2100; i++) {
        [self.yearsData addObject:[NSString stringWithFormat:@"%04ld",(long)i]];
    }
    for (NSInteger i = 1; i < 13; i++) {
        [self.monthsData addObject:[NSString stringWithFormat:@"%02ld",(long)i]];
    }
    for (NSInteger i = 1; i < daysInOfMonth.length+1; i++) {
        [self.daysData addObject:[NSString stringWithFormat:@"%02ld",(long)i]];
    }
    for (NSInteger i = 0; i < 24; i++) {
        [self.hoursData addObject:[NSString stringWithFormat:@"%02ld",(long)i]];
    }
    for (NSInteger i = 0; i < 60; i++) {
        [self.minutesData addObject:[NSString stringWithFormat:@"%02ld",(long)i]];
    }
    
    [self scrollToDay:nextDay];
    
    [self handleSelectTime:self.pickerView];
}

- (void)scrollToDay:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone localTimeZone]];
    //后一天
//    NSDate *toDay = [NSDate date];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute) fromDate:date];
    [self.pickerView selectRow:[self.yearsData indexOfObject:[NSString stringWithFormat:@"%04ld",(long)components.year]] inComponent:0 animated:YES];
    [self.pickerView selectRow:[self.monthsData indexOfObject:[NSString stringWithFormat:@"%02ld",(long)components.month]] inComponent:1 animated:YES];
    [self.pickerView selectRow:[self.daysData indexOfObject:[NSString stringWithFormat:@"%02ld",(long)components.day]] inComponent:2 animated:YES];
    [self.pickerView selectRow:[self.hoursData indexOfObject:[NSString stringWithFormat:@"%02ld",(long)components.hour]] inComponent:3 animated:YES];
    [self.pickerView selectRow:[self.minutesData  indexOfObject:[NSString stringWithFormat:@"%02ld",(long)components.minute]] inComponent:4 animated:YES];
}

- (void)initView {
    self.backgroundColor = [UIColor whiteColor];
    self.pickerView = [[UIPickerView alloc] initWithFrame:self.bounds];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    [self addSubview:self.pickerView];
    CGFloat Width = self.width/5;
    NSArray * titles = @[@"年", @"月", @"日", @"时", @"分"];
    for (NSInteger i = 0; i < titles.count; i++) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(Width*i + Width-20, self.height/2-10, 20, 20)];
        label.text = titles[i];
        label.textAlignment = NSTextAlignmentLeft;
        [self.pickerView addSubview:label];
    }
    self.layer.cornerRadius = 10;
}

#pragma mark --UIPickerViewDataSource,UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 5;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.yearsData.count;
    } else if (component == 1) {
        return self.monthsData.count;
    } else if (component == 2) {
        return self.daysData.count;
    } else if (component == 3) {
        return self.hoursData.count;
    } else {
        return self.minutesData.count;
    }
}
//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
//    if (component == 0) {
//        return 100;
//    } else {
//        return 50;
//    }
//}
//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    if (component == 0) {
//        return [self.yearsData objectAtIndex:row];
//    } else if (component == 1) {
//        return [self.monthsData objectAtIndex:row];
//    } else if (component == 2) {
//        return [self.daysData objectAtIndex:row];
//    } else if (component == 3) {
//        return [self.hoursData objectAtIndex:row];
//    } else {
//        return [self.minutesData objectAtIndex:row];
//    }
//}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    if (!view) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width/5, 20)];
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.width-25, 20)];
        timeLabel.tag = 10;
        [timeLabel setTextAlignment:NSTextAlignmentRight];
        [timeLabel setFont:[UIFont systemFontOfSize:17]];
        [view addSubview:timeLabel];
    }
    
    UILabel *timeLabel = [view viewWithTag:10];
    if (component == 0) {
        timeLabel.text = [NSString stringWithFormat:@"%@",self.yearsData[row]];
    } else if (component == 1) {
        timeLabel.text = [NSString stringWithFormat:@"%@",self.monthsData[row]];
    } else if (component == 2) {
        timeLabel.text = [NSString stringWithFormat:@"%@",self.daysData[row]];
    } else if (component == 3) {
        timeLabel.text = [NSString stringWithFormat:@"%@",self.hoursData[row]];
    } else {
        timeLabel.text = [NSString stringWithFormat:@"%@",self.minutesData[row]];
    }
    
    return view;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self handleSelectTime:pickerView];
}

- (void)handleSelectTime:(UIPickerView *)pickerView {
    NSString * yearStr = [NSString stringWithFormat:@"%@",self.yearsData[[pickerView selectedRowInComponent:0]]];
    NSString * monthStr = [NSString stringWithFormat:@"%@",self.monthsData[[pickerView selectedRowInComponent:1]]];
    NSString * dayStr = [NSString stringWithFormat:@"%@",self.daysData[[pickerView selectedRowInComponent:2]]];
    NSString * hourStr = [NSString stringWithFormat:@"%@",self.hoursData[[pickerView selectedRowInComponent:3]]];
    NSString * minuteStr = [NSString stringWithFormat:@"%@",self.minutesData[[pickerView selectedRowInComponent:4]]];
    
    NSString * selectTimeStr = [NSString stringWithFormat:@"%@/%@/%@ %@:%@", yearStr, monthStr, dayStr, hourStr, minuteStr];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    NSDate * selectTime = [formatter dateFromString:selectTimeStr];
    
    NSDate * currentDate = [NSDate date];
    NSComparisonResult result = [selectTime compare:currentDate];
    if (result == NSOrderedAscending) {
        // 时间已经过期
        [self scrollToDay:currentDate];
        // 可以设置
        if (self.pickerResultBlock) {
            self.pickerResultBlock([formatter stringFromDate:currentDate]);
        }
    } else {
        // 可以设置
        if (self.pickerResultBlock) {
            self.pickerResultBlock(selectTimeStr);
        }
    }
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
