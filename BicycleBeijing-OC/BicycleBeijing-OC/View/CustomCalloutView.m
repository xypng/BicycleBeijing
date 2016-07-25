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
const NSInteger kMoveBarHeight = 30;

#define CellID @"ClusterTableViewCell"

@interface CustomCalloutView()
{
    BOOL _isMoved;//是否是在移动
    CGFloat _y;//移动时点下去时的y
}

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

        self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9];

        self.tableview = [[UITableView alloc] init];
        self.tableview.bounces = NO;
        self.tableview.rowHeight = UITableViewAutomaticDimension;
        self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableview registerNib:[UINib nibWithNibName:CellID bundle:nil] forCellReuseIdentifier:CellID];
        self.tableview.delegate = self;
        self.tableview.dataSource = self;

        CGFloat lineWidth = 30.0;
        CGFloat lineHeight = 2.0;
        CGFloat lineSpace = 2.0;
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-lineWidth)/2, (kMoveBarHeight-lineHeight*3-lineSpace*2)/2, lineWidth, lineHeight)];
        view1.backgroundColor = [UIColor grayColor];
        view1.layer.cornerRadius = 1.0;
        UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-lineWidth)/2, (kMoveBarHeight-lineHeight*3-lineSpace*2)/2 + (lineHeight+lineSpace), lineWidth, lineHeight)];
        view2.layer.cornerRadius = 1.0;
        view2.backgroundColor = [UIColor grayColor];
        UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-lineWidth)/2, (kMoveBarHeight-lineHeight*3-lineSpace*2)/2 + (lineHeight+lineSpace)*2, lineWidth, lineHeight)];
        view3.layer.cornerRadius = 1.0;
        view3.backgroundColor = [UIColor grayColor];
        [self addSubview:view1];
        [self addSubview:view2];
        [self addSubview:view3];

        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, kMoveBarHeight-0.5, SCREEN_WIDTH, 0.5);
        layer.backgroundColor = RGBA(214, 214, 214, 1).CGColor;
        [self.layer addSublayer:layer];
        
        [self addSubview:self.tableview];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:[touch view]];
    if (point.y <= kMoveBarHeight) {
        _isMoved = YES;
        _y = point.y;
        DLog(@"move");
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_isMoved) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:[touch view].superview];
    DLog(@"%@", NSStringFromCGPoint(point));
    self.frame = CGRectMake(0, point.y-_y, SCREEN_WIDTH, SCREEN_HEIGHT-(point.y-_y));
    self.tableview.frame = CGRectMake(0, kMoveBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT-(point.y-_y)-kMoveBarHeight);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _isMoved = NO;
    DLog(@"endMove");
}

@end
