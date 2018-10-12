//
//  MainCollectionView.h
//  IntelligentLock
//
//  Created by shenzhenshihua on 2018/10/12.
//  Copyright © 2018年 liangzhen. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^SelectBlock)(NSInteger selectIndex);
typedef void(^ScrollBlock)(CGFloat scrollY, BOOL endScroll);
@interface MainCollectionView : UICollectionView
@property(nonatomic,copy)ScrollBlock scrollBlock;

+ (id)mainCollectionViewWithFrame:(CGRect)frame DataSource:(NSArray *)dataSource selectBlock:(SelectBlock)selectBlock;
@end
