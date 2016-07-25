//
//  ClusterTableViewCell.m
//  BicycleBeijing-OC
//
//  Created by XiaoYiPeng on 16/7/22.
//  Copyright © 2016年 XiaoYiPeng. All rights reserved.
//

#import "ClusterTableViewCell.h"
#import "Bicycle.h"

@implementation ClusterTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateWithBicycle:(Bicycle *)bicycle {
    self.nameLabel.text = bicycle.name;
    self.addressLabel.text = bicycle.address;
    self.numLabel.text = [NSString stringWithFormat:@"锁车器：%ld", (long)bicycle.num];
}

@end
