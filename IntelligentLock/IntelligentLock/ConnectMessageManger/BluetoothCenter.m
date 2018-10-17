//
//  BluetoothCenter.m
//  BluetoothDemo
//
//  Created by shenzhenshihua on 2018/9/25.
//  Copyright © 2018年 shenzhenshihua. All rights reserved.
//

#import "BluetoothCenter.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "Tools.h"
#import "AlertConreoller.h"

@interface BluetoothCenter ()<CBCentralManagerDelegate,CBPeripheralDelegate>
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;
@property(nonatomic,assign)BluetoothLockState lockState;
@property(nonatomic,copy)SendCommandBlock commandBlock;
@property(nonatomic,copy)ConnectBlock connectBlock;
@property(nonatomic,assign)BOOL isNotFristScan;
@end
static BluetoothCenter * _bluetoothCenter;
static NSString * const commandOn = @"ff";  ///< 开启
static NSString * const commandOff = @"00"; ///< 关闭

@implementation BluetoothCenter
+ (id)shareBluetoothCenter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_bluetoothCenter == nil) {
            _bluetoothCenter = [[BluetoothCenter alloc] init];
        }
    });
    return _bluetoothCenter;
}
- (void)bluetoothLockConnectCompletion:(ConnectBlock)connectBlock {
    self.connectBlock = connectBlock;
    // 初始化蓝牙 并且链接
    [self initBluetoothCenter];
}
/**
 初始化蓝牙
 */
- (void)initBluetoothCenter {
    dispatch_queue_t globleQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:globleQueue];
}

/**
 处理 蓝牙的 连接状态设置 通过block 通知链接方

 @param linkState 蓝牙的连接状态
 */
- (void)handleLinkState:(BluetoothLockLinkState)linkState {
    self.linkState = linkState;
    if (self.connectBlock) {
        self.connectBlock(linkState);
    }
}
#pragma mark --CBCentralManagerDelegate
/** 判断手机蓝牙状态
 CBManagerStateUnknown = 0,  未知
 CBManagerStateResetting,    重置中
 CBManagerStateUnsupported,  不支持
 CBManagerStateUnauthorized, 未验证
 CBManagerStatePoweredOff,   未启动
 CBManagerStatePoweredOn,    可用
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStatePoweredOn:
            {// 可用
                MPNLog(@"可用");
                //开始扫描设备
                [central scanForPeripheralsWithServices:nil options:nil];
            }
            break;
        case CBManagerStatePoweredOff:
            {// 关闭可用
                 //拒绝了开启
                [self handleLinkState:BluetoothLockLinkStateOff];
//                if (_isNotFristScan) {
//                    // 拒绝了开启
//                    [self handleLinkState:BluetoothLockLinkStateOff];
//                } else {
//                    __weak typeof (self)ws = self;
//                    [AlertConreoller alertControllerWithController:nil title:@"提示" message:@"请你打开蓝牙开关" cancelButtonTitle:@"暂不打开" otherButtonTitle:@"现在设置" cancelAction:^{
//                        // 拒绝了开启
//                        [self handleLinkState:BluetoothLockLinkStateOff];
//                        ws.isNotFristScan = YES;
//                    } otherAction:^{
//                        // 跳到设置界面去设置
//                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
//                    }];
//                }
            }
            break;
        case CBManagerStateUnsupported:
            {// 不支持
                [self handleLinkState:BluetoothLockLinkStateOff];
            }
            break;
        case CBManagerStateUnauthorized:
            {// 没有授权
            
            }
            break;
        default:
            break;
    }
}
/** 发现符合要求的外设，回调 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    // 只连接 BK_91FFDDCC 这个的蓝牙
    if ([advertisementData[@"kCBAdvDataLocalName"] isEqualToString:@"BK_91FFDDCC"]) {
        self.peripheral = peripheral;
        // 连接 设备
        [central connectPeripheral:peripheral options:nil];
    } else {
        [self handleLinkState:BluetoothLockLinkStateOff];
    }
    MPNLog(@"%@-----%@---%@", peripheral.identifier, advertisementData, RSSI);
}
/** 连接成功 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    // 停止扫描
    [self.centralManager stopScan];
    // 设置链接状态
    [self handleLinkState:BluetoothLockLinkStateOn];
    // 设置 外设 代理
    peripheral.delegate = self;
    // 寻找服务 (三个方法  分别是: uuid  特征值 和uuid+服务) nil 搜寻所有的
    [peripheral discoverServices:nil];
}
/** 连接失败的回调 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    // 设置链接状态
    [self handleLinkState:BluetoothLockLinkStateOff];
    MPNLog(@"连接失败的原因：%@", error);
}
/** 断开连接 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    MPNLog(@"断开连接的原因：%@", error);
    // 设置链接状态
    [self handleLinkState:BluetoothLockLinkStateOff];
    // 断开连接可以重新连接
    [central connectPeripheral:peripheral options:nil];
}
#pragma mark --CBCentralManagerDelegate--end

#pragma mark --CBPeripheralDelegate
/** 发现服务 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    // 遍历出外设中所有的服务
    for (CBService *service in peripheral.services) {
        // 只有 uuid 为 FEE0 才是正确的服务
        if ([service.UUID.UUIDString isEqualToString:@"FEE0"]) {
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}
/** 发现特征回调 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
    // 遍历出所需要的特征
    for (CBCharacteristic *characteristic in service.characteristics) {
        MPNLog(@"所有特征：%@", characteristic);
        // 从外设开发人员那里拿到不同特征的UUID，不同特征做不同事情，比如有读取数据的特征，也有写入数据的特征
    }
    
    // 这里只获取一个特征，写入数据的时候需要用到这个特征
    self.characteristic = service.characteristics.firstObject;
    MPNLog(@"%@",self.characteristic.description);
    
    /*
     直接读取这个特征数据，会调用didUpdateValueForCharacteristic
    [peripheral readValueForCharacteristic:self.characteristic];
     订阅通知
    [peripheral setNotifyValue:YES forCharacteristic:self.characteristic];
     */
}
/** 订阅状态的改变 */
/* 当前的设备不支持 订阅
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        MPNLog(@"订阅失败");
        MPNLog(@"%@",error);
    }
    if (characteristic.isNotifying) {
        MPNLog(@"订阅成功");
    } else {
        MPNLog(@"取消订阅");
    }
}*/
/** 接收到数据回调 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    // 拿到外设发送过来的数据
    MPNLog(@"拿到外设发送过来的数据");
        NSData *data = characteristic.value;
    //    self.textField.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    MPNLog(@"666%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}
/** 写入数据回调 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    MPNLog(@"写入成功:%@---%@",[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding],error);
    if (self.commandBlock) {
        self.commandBlock(self.lockState);
    }
}
#pragma mark --CBPeripheralDelegate --end

#pragma mark --send command
// 写入命令
- (void)sendCommandState:(BOOL)lock completion:(SendCommandBlock)commandBlock {
    self.commandBlock = commandBlock;
    NSString * commandStr = nil;
    if (lock) {
        commandStr = commandOn;
        _lockState = BluetoothLockStateUnLock;
    } else {
        commandStr = commandOff;
        _lockState = BluetoothLockStateLock;
    }
    // 将指令转换为 16 进制的方式
    NSData *data = [[Tools shareTools] convertHexStrToData:commandStr];

    [self.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
}

    
@end
