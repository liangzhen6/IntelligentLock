//
//  GCDAsyncSocket+HeartBeat.h
//  IntelligentLock
//
//  Created by liangzhen on 2019/2/16.
//  Copyright © 2019年 liangzhen. All rights reserved.
//

#import <GCDAsyncSocket.h>

NS_ASSUME_NONNULL_BEGIN

@interface GCDAsyncSocket (HeartBeat)
@property(nonatomic)NSInteger hB_countdown;
@property(nonatomic)dispatch_source_t time;

- (void)startHeartBeat;
@end

NS_ASSUME_NONNULL_END
