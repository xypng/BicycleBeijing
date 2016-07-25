//
//  CustomCalloutView.m
//  iOS_3D_ClusterAnnotation
//
//  Created by PC on 15/7/9.
//  Copyright (c) 2015年 FENGSHENG. All rights reserved.
//

#import "CustomCalloutView.h"
#import "ClusterTableViewCell.h"
#import "Bicycle.h"

const NSInteger kMaxHeight = 225;
const NSInteger kCellHeight = 120;
const NSInteger kMoveBarHeight = 20;

#define CellID @"ClusterTableViewCell"

@interface CustomCalloutView()

@property (nonatomic, strong) UITableView *tableview;

@end

@implementation CustomCalloutView

- (void)setPoiArray:(NSArray *)poiArrayy
{
    _poiArray = [NSArray arrayWithArray:poiArrayy];
    CGFloat totalHeight = kCellHeight * self.poiArray.count+kMoveBarHeight;
    CGFloat height = MIN(totalHeight, kMaxHeight);

    self.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, height);
    
    self.tableview.frame = CGRectMake(0, kMoveBarHeight, SCREEN_WIDTH, height-kMoveBarHeight);

    [UIView animateWithDuration:0.5 animations:^{
        self.frame = CGRectMake(0, SCREEN_HEIGHT-height, SCREEN_WIDTH, height);
    } completion:^(BOOL finished) {

    }];

    [self.tableview reloadData];
}

- (void)dismissCalloutView
{
    self.poiArray = nil;
    [self removeFromSuperview];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return kCellHeight;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.poiArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClusterTableViewCell *cell = (ClusterTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    Bicycle *bicycle = [self.poiArray objectAtIndex:indexPath.row];
    [cell updateWithBicycle:bicycle];
    return cell;
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {

        self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];

        self.tableview = [[UITableView alloc] init];
        self.tableview.bounces = NO;
        self.tableview.rowHeight = UITableViewAutomaticDimension;
        self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableview registerNib:[UINib nibWithNibName:CellID bundle:nil] forCellReuseIdentifier:CellID];
        self.tableview.delegate = self;
        self.tableview.dataSource = self;
        
        [self addSubview:self.tableview];
    }
    return self;
}

@end
