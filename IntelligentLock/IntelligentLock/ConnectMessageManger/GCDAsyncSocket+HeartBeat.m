//
//  GCDAsyncSocket+HeartBeat.m
//  IntelligentLock
//
//  Created by liangzhen on 2019/2/16.
//  Copyright © 2019年 liangzhen. All rights reserved.
//

#import "GCDAsyncSocket+HeartBeat.h"
#import <objc/runtime.h>
#import "Socket.h"

#define DefaultCountdown 15;

@implementation GCDAsyncSocket (HeartBeat)
+ (void)load {
    Method socketWrite = class_getInstanceMethod(self, @selector(writeData:withTimeout:tag:));
    Method heartBeat_socketWrite = class_getInstanceMethod(self, @selector(hb_writeData:withTimeout:tag:));
    
    method_exchangeImplementations(socketWrite, heartBeat_socketWrite);
}

- (void)hb_writeData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag {
    [self hb_writeData:data withTimeout:timeout tag:tag];
    self.hB_countdown = DefaultCountdown;
}

- (void)startHeartBeat {
    if (!self.time) {
        self.hB_countdown = DefaultCountdown;
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0);
        self.time = timer;
        dispatch_source_set_event_handler(timer, ^{
            self.hB_countdown--;
        });
        dispatch_resume(timer);
    }
}

- (void)setHB_countdown:(NSInteger)hB_countdown {
    NSLog(@"当前时间%ld", (long)hB_countdown);
//    if (hB_countdown <= 0) {
//        [[Socket shareSocket] handleHeart];
//    } else {
//        objc_setAssociatedObject(self, "countdown", @(hB_countdown), OBJC_ASSOCIATION_ASSIGN);
//    }
    objc_setAssociatedObject(self, "countdown", @(hB_countdown), OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)hB_countdown {
    NSInteger hB_countdown = [objc_getAssociatedObject(self, "countdown") integerValue];
    if (hB_countdown <= 0) {
        [[Socket shareSocket] handleHeart];
    }
    return [objc_getAssociatedObject(self, "countdown") integerValue];
}

- (void)setTime:(dispatch_source_t)time {
    objc_setAssociatedObject(self, "time", time, OBJC_ASSOCIATION_RETAIN);
}

- (dispatch_source_t)time {
    return objc_getAssociatedObject(self, "time");
}

@end
