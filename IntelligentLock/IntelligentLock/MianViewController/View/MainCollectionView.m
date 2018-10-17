//
//  MainCollectionView.m
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/10/12.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import "MainCollectionView.h"
#import "MainCollectionViewCell.h"
#import "HeardCollectionReusableView.h"
#import "HeaderUnNetWorkCollectionReusableView.h"
#import "MainCollectionModel.h"
#import "LockConnectManger.h"
#import "Tools.h"
#import "User.h"

@interface MainCollectionView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property(nonatomic,strong)NSMutableArray * collectionData;
@property(nonatomic,copy)SelectBlock selectBlock;
@end
static NSString *const collectionCellId = @"collectionCellId";
static NSString *const collectionHeaderId = @"collectionHeaderId";
static NSString *const collectionHeaderUnNetWorkId = @"collectionHeaderUnNetWorkId";

@implementation MainCollectionView

+ (id)mainCollectionViewWithFrame:(CGRect)frame DataSource:(NSArray *)dataSource selectBlock:(SelectBlock)selectBlock {
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat Width = (Screen_Width-32)/3;
    layout.itemSize = CGSizeMake(Width, Width);
    layout.minimumLineSpacing = 1;
    layout.minimumInteritemSpacing = 1;
    layout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
//    layout.headerReferenceSize = CGSizeMake(Screen_Width, 40);
    // 设置一个透明的footer 视图撑场
    layout.footerReferenceSize = CGSizeMake(Screen_Width, Screen_Height-NavBarHeight-40-Width);
    MainCollectionView * mainView = [[MainCollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    mainView.collectionData = [dataSource mutableCopy];
    mainView.selectBlock = selectBlock;
    [mainView initCollectionView];
    
    return mainView;
}
- (void)initCollectionView {
//    self.backgroundColor = RGBColor(250.0, 249.0, 250.0);
    self.backgroundColor = [UIColor clearColor];
    self.showsVerticalScrollIndicator = NO;
    self.delegate = self;
    self.dataSource = self;
    // 注册cell
    UINib * cellNib = [UINib nibWithNibName:NSStringFromClass([MainCollectionViewCell class]) bundle:nil];
    [self registerNib:cellNib forCellWithReuseIdentifier:collectionCellId];
    // 注册 header
    UINib * headerNib = [UINib nibWithNibName:NSStringFromClass([HeardCollectionReusableView class]) bundle:nil];
    [self registerNib:headerNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:collectionHeaderId];
    // 注册 无网络的header
    UINib *unNetWorkNib = [UINib nibWithNibName:NSStringFromClass([HeaderUnNetWorkCollectionReusableView class]) bundle:nil];
    [self registerNib:unNetWorkNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:collectionHeaderUnNetWorkId];
    
    [self registerNib:headerNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:collectionHeaderId];
    
    // 增加网络状态的监听
    [[LockConnectManger shareLockConnectManger] addObserver:self forKeyPath:@"netWorkState" options:NSKeyValueObservingOptionNew context:nil];

}
// 更新链接状态
- (void)updateConnectState:(ConnectState)connectState {
    for (MainCollectionModel *model in self.collectionData) {
        model.connectState = connectState;
    }
    [self reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

//增加或者删除一个 设备的 item
- (void)handleDeviceItemChange:(DeviceBackType)backType itemModel:(MainCollectionModel *)model {
    if (backType == DeviceBackTypeAddDevice) {
        // 增加
        [self.collectionData insertObject:model atIndex:self.collectionData.count-1];
        [[[User shareUser] devicesArr] addObject:model];
    } else {
        // 删除一个
        [self.collectionData removeObject:model];
        [[[User shareUser] devicesArr] removeObject:model];

    }
    // 刷新UI
    [self reloadSections:[NSIndexSet indexSetWithIndex:0]];
    // 本地存储数据
    [[Tools shareTools] writeID:self.collectionData pathString:Device_Data_Key];
}

#pragma mark -- UICollectionViewDelegate UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.collectionData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MainCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellId forIndexPath:indexPath];
    cell.model = self.collectionData[indexPath.item];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        // 是头部
        if ([[LockConnectManger shareLockConnectManger] netWorkState] == NetWorkStateOff) {
            // 无网络
            HeaderUnNetWorkCollectionReusableView * headerUnNetWorkCollectionReusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:collectionHeaderUnNetWorkId forIndexPath:indexPath];
            [headerUnNetWorkCollectionReusableView addTitle:@"我的设备"];
            return headerUnNetWorkCollectionReusableView;
        } else {
            HeardCollectionReusableView * headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:collectionHeaderId forIndexPath:indexPath];
            [headerView addTitle:@"我的设备"];
            return headerView;
        }
    }
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:collectionHeaderId forIndexPath:indexPath];
}

// 点击了item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectBlock) {
        self.selectBlock(self.collectionData[indexPath.item]);
    }
}

#pragma --UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if ([[LockConnectManger shareLockConnectManger] netWorkState] == NetWorkStateOff) {
        // 无网络
        return CGSizeMake(Screen_Width, 70);
    } else {
        return CGSizeMake(Screen_Width, 40);
    }
}

#pragma mark -- kvo监听网络状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"netWorkState"]) {
        [self reloadData];
    }
}

// 滚动的时候
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    if (self.scrollBlock) {
        self.scrollBlock(contentOffsetY, NO);
    }
}

// 停止滚动的时候
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    if (self.scrollBlock) {
        self.scrollBlock(contentOffsetY, YES);
    }
}

// 松手后调用
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        // 用户松手后不会再滑动了
        CGFloat contentOffsetY = scrollView.contentOffset.y;
        if (self.scrollBlock) {
            self.scrollBlock(contentOffsetY, YES);
        }
    }
}

- (void)dealloc {
    [[LockConnectManger shareLockConnectManger] removeObserver:self name:@"netWorkState" object:nil];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
