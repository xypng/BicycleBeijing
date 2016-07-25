//
//  ClusterTableViewCell.m
//  BicycleBeijing-OC
//
//  Created by XiaoYiPeng on 16/7/22.
//  Copyright © 2016年 XiaoYiPeng. All rights reserved.
//

#import "ClusterTableViewCell.h"
#import "Bicycle.h"

@interface ClusterTableViewCell()
{

}
@property (weak, nonatomic) IBOutlet UIView *seperatorView;

@end

@implementation ClusterTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    //分隔线的高
    CGFloat lineHeight = 0.5;

    CALayer *layerTop = [CALayer layer];
    layerTop.frame = CGRectMake(0, 0, SCREEN_WIDTH, lineHeight);
    layerTop.backgroundColor = RGBA(214, 214, 214, 1).CGColor;

    CALayer *layerBottom = [CALayer layer];
    layerBottom.frame = CGRectMake(0, self.seperatorView.frame.size.height-lineHeight, SCREEN_WIDTH, lineHeight);
    layerBottom.backgroundColor = RGBA(214, 214, 214, 1).CGColor;

    [self.seperatorView.layer addSublayer:layerTop];
    [self.seperatorView.layer addSublayer:layerBottom];
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
