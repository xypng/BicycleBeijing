//
//  ClusterTableViewCell.h
//  BicycleBeijing-OC
//
//  Created by XiaoYiPeng on 16/7/22.
//  Copyright © 2016年 XiaoYiPeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Bicycle;

@interface ClusterTableViewCell : UITableViewCell
/**
 *  站名
 */
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
/**
 *  地址
 */
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
/**
 *  锁车器数
 */
@property (weak, nonatomic) IBOutlet UILabel *numLabel;

/**
 *  更新cell
 *
 *  @param bicycle model
 */
- (void)updateWithBicycle:(Bicycle *)bicycle;

@end
