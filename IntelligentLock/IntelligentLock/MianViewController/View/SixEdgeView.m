//
//  SixEdgeView.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/10/12.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "SixEdgeView.h"
@interface SixEdgeView ()
@property(nonatomic,strong)UILabel * numberLabel;
@end
@implementation SixEdgeView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    // 布局UI相关
    UILabel * numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.width/2-70, self.height/2-45, 80, 55)];
    numberLabel.textColor = [UIColor whiteColor];
    numberLabel.font = [UIFont boldSystemFontOfSize:70];
    numberLabel.text = @"0";
    numberLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:numberLabel];
    _numberLabel = numberLabel;
    
    UILabel * title1Label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(numberLabel.frame)+10, self.height/2-10, 30, 20)];
    title1Label.font = [UIFont boldSystemFontOfSize:18];
    title1Label.textColor = [UIColor whiteColor];
    title1Label.text = @"个";
    [self addSubview:title1Label];
    
    UILabel * title2Label = [[UILabel alloc] initWithFrame:CGRectMake(self.width/2-60, self.height/2+20, 120, 20)];
    title2Label.font = [UIFont boldSystemFontOfSize:18];
    title2Label.textColor = [UIColor whiteColor];
    title2Label.textAlignment = NSTextAlignmentCenter;
    title2Label.text = @"设备连接";
    [self addSubview:title2Label];
    
    
    // 绘制边框相关
    UIColor *color = [UIColor whiteColor];
    [color set];
    CGPoint point1 = CGPointMake(self.width/2, 0);
    CGPoint point2 = CGPointMake(self.width, self.height/4);
    CGPoint point3 = CGPointMake(self.width, self.height*3/4);
    CGPoint point4 = CGPointMake(self.width/2, self.height);
    CGPoint point5 = CGPointMake(0, self.height*3/4);
    CGPoint point6 = CGPointMake(0, self.height/4);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 2;
    [path moveToPoint:point1];
    [path addLineToPoint:point2];
    [path addLineToPoint:point3];
    [path addLineToPoint:point4];
    [path addLineToPoint:point5];
    [path addLineToPoint:point6];
    [path addLineToPoint:point1];


    CGPoint point7 = CGPointMake(self.width/2, 4);
    CGPoint point8 = CGPointMake(self.width-3.46, self.height/4+2);
    CGPoint point9 = CGPointMake(self.width-3.46, self.height*3/4-2);
    CGPoint point10 = CGPointMake(self.width/2, self.height-4);
    CGPoint point11 = CGPointMake(3.46, self.height*3/4-2);
    CGPoint point12 = CGPointMake(3.46, self.height/4+2);
    
//    CGPoint point7 = CGPointMake(self.width/2, 2);
//    CGPoint point8 = CGPointMake(self.width-1.73, self.height/4+1);
//    CGPoint point9 = CGPointMake(self.width-1.73, self.height*3/4-1);
//    CGPoint point10 = CGPointMake(self.width/2, self.height-2);
//    CGPoint point11 = CGPointMake(1.73, self.height*3/4-1);
//    CGPoint point12 = CGPointMake(1.73, self.height/4+1);
    [path addLineToPoint:point7];
    [path addLineToPoint:point12];
    [path addLineToPoint:point11];
    [path addLineToPoint:point10];
    [path addLineToPoint:point9];
    [path addLineToPoint:point8];
    [path addLineToPoint:point7];

    
    CAShapeLayer * shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.shadowRadius = 10;
    shapeLayer.shadowOpacity = 1.0;
    shapeLayer.shadowOffset = CGSizeMake(0, 0);
    shapeLayer.shadowColor = [UIColor whiteColor].CGColor;
    shapeLayer.fillColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:shapeLayer];

    //监听进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    //监听进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)startAnimation {
    CAShapeLayer *shapeLayer = nil;
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer isKindOfClass:[CAShapeLayer class]]) {
            shapeLayer = (CAShapeLayer*)layer;
        }
    }
    if (shapeLayer) {
        // 设置呼吸灯效果 opacity
        CABasicAnimation * opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacity.fromValue = [NSNumber numberWithFloat:1.0];
        opacity.toValue = [NSNumber numberWithFloat:0.2];
        opacity.duration = 5.0;
        // 执行可逆动画
        opacity.autoreverses = YES;
        // 设置永远执行动画
        opacity.repeatCount = MAXFLOAT;
        [shapeLayer addAnimation:opacity forKey:@"opacity"];
    }
   
}
- (void)endAnimation {
    CAShapeLayer *shapeLayer = nil;
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer isKindOfClass:[CAShapeLayer class]]) {
            shapeLayer = (CAShapeLayer*)layer;
        }
    }
    if (shapeLayer) {
        // 移除呼吸灯效果 opacity
        [shapeLayer removeAnimationForKey:@"opacity"];
    }
}

- (void)updateDeviceNumber:(NSString *)deviceNumberStr {
    if ([deviceNumberStr length]) {
        _numberLabel.text = deviceNumberStr;
    }
}

//进入前台
- (void)becomeActive {
    [self startAnimation];
}
//进入后台
- (void)enterBackground {
    [self endAnimation];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
