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
#import "ViewController.h"

const NSInteger kMaxHeight = 225;
const NSInteger kCellHeight = 120;
const NSInteger kMoveBarHeight = 30;

#define CellID @"ClusterTableViewCell"

@interface CustomCalloutView()
{
    BOOL _canMoved;//是否可以移动
    BOOL _isMoved;//是否是在移动
    CGFloat _y;//移动时点下去时的y
}

@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) UIView *view1;
@property (nonatomic, strong) UIView *view2;
@property (nonatomic, strong) UIView *view3;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *titleLabel;

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
        CGRect toRect = CGRectMake(0, SCREEN_HEIGHT-height, SCREEN_WIDTH, height);
        self.frame = toRect;
        if ([self.delegate respondsToSelector:@selector(customCalloutView:willChangeFrame:)]) {
            [self.delegate customCalloutView:self willChangeFrame:toRect];
        }
    } completion:^(BOOL finished) {

    }];

    [self.tableview reloadData];
}

- (void)dismissCalloutView
{
    self.poiArray = nil;
    [self removeFromSuperview];
    self.view1.alpha = 1.0;
    self.view2.alpha = 1.0;
    self.view3.alpha = 1.0;
    self.titleLabel.alpha = 0.0;
    self.backButton.alpha = 0.0;
    self.lineView.frame = CGRectMake(0, kMoveBarHeight-0.5, SCREEN_WIDTH, 0.5);
    _canMoved = YES;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.poiArray.count<=1) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(customCalloutView:didDetailButtonTapped:)]) {
        [self.delegate customCalloutView:self didDetailButtonTapped:indexPath.row];
    }
}
#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _canMoved = YES;

        self.backgroundColor = [UIColor whiteColor];

        self.tableview = [[UITableView alloc] init];
        self.tableview.bounces = NO;
        self.tableview.rowHeight = UITableViewAutomaticDimension;
        self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableview registerNib:[UINib nibWithNibName:CellID bundle:nil] forCellReuseIdentifier:CellID];
        self.tableview.delegate = self;
        self.tableview.dataSource = self;
        [self addSubview:self.tableview];

        //添加拖动按钮的图按（是三根横线）
        CGFloat lineWidth = 30.0;
        CGFloat lineHeight = 2.0;
        CGFloat lineSpace = 2.0;
        self.view1 = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-lineWidth)/2, (kMoveBarHeight-lineHeight*3-lineSpace*2)/2, lineWidth, lineHeight)];
        self.view1.backgroundColor = [UIColor grayColor];
        self.view1.layer.cornerRadius = 1.0;
        self.view2 = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-lineWidth)/2, (kMoveBarHeight-lineHeight*3-lineSpace*2)/2 + (lineHeight+lineSpace), lineWidth, lineHeight)];
        self.view2.layer.cornerRadius = 1.0;
        self.view2.backgroundColor = [UIColor grayColor];
        self.view3 = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-lineWidth)/2, (kMoveBarHeight-lineHeight*3-lineSpace*2)/2 + (lineHeight+lineSpace)*2, lineWidth, lineHeight)];
        self.view3.layer.cornerRadius = 1.0;
        self.view3.backgroundColor = [UIColor grayColor];
        [self addSubview:self.view1];
        [self addSubview:self.view2];
        [self addSubview:self.view3];

        //添加标题
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, SCREEN_WIDTH, NAVIGATION_BAR_HEIGHT)];
        self.titleLabel.backgroundColor = [UIColor whiteColor];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.text = @"网点列表";
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.alpha = 0.0;
        [self addSubview:self.titleLabel];

        //添加返回按钮
        self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.backButton.frame = CGRectMake(0, STATUS_BAR_HEIGHT, 50, 44);
        [self.backButton setTitle:@"返回" forState:UIControlStateNormal];
        [self.backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.backButton.backgroundColor = [UIColor whiteColor];
        self.backButton.alpha = 0.0;
        [self addSubview:self.backButton];

        //添加分隔线
        self.lineView = [[UIView alloc] init];
        self.lineView.frame = CGRectMake(0, kMoveBarHeight-0.5, SCREEN_WIDTH, 0.5);
        self.lineView.backgroundColor = RGBA(214, 214, 214, 1);
        [self addSubview:self.lineView];

    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:[touch view]];
    if (_canMoved && point.y <= kMoveBarHeight) {
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
//    if (self.tableview.contentSize.height<SCREEN_HEIGHT-(point.y-_y)-kMoveBarHeight) {
//        return;
//    }
    CGRect toRect = CGRectMake(0, point.y-_y, SCREEN_WIDTH, SCREEN_HEIGHT-(point.y-_y));
    self.frame = toRect;
    self.tableview.frame = CGRectMake(0, kMoveBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT-(point.y-_y)-kMoveBarHeight);
    if ([self.delegate respondsToSelector:@selector(customCalloutView:willChangeFrame:)]) {
        [self.delegate customCalloutView:self willChangeFrame:toRect];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _isMoved = NO;
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:[touch view].superview];
    DLog(@"endMove");
    if (point.y < SCREEN_HEIGHT/2.0) {
        [UIView animateWithDuration:0.5 animations:^{
            self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            self.tableview.frame = CGRectMake(0, STATUS_AND_NAVIGATION_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-STATUS_AND_NAVIGATION_HEIGHT);
            self.view1.alpha = 0;
            self.view2.alpha = 0;
            self.view3.alpha = 0;
            self.lineView.frame = CGRectMake(0, STATUS_AND_NAVIGATION_HEIGHT-0.5, SCREEN_WIDTH, 0.5);
            self.backButton.alpha = 1.0;
            self.titleLabel.alpha = 1.0;
            if ([self.delegate respondsToSelector:@selector(customCalloutView:willChangeFrame:)]) {
                [self.delegate customCalloutView:self willChangeFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            }
        } completion:^(BOOL finished) {
            _canMoved = NO;
        }];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _isMoved = NO;
}

@end
