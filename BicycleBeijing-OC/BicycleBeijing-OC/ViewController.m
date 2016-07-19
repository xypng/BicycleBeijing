//
//  ViewController.m
//  BicycleBeijing-OC
//
//  Created by XiaoYiPeng on 16/7/19.
//  Copyright © 2016年 XiaoYiPeng. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "ImageUtilities.h"

@interface ViewController ()<MAMapViewDelegate, AMapSearchDelegate>
{
    //地图
    MAMapView *_mapView;
    //当前位置
    CLLocationCoordinate2D _currentCoordiate;
    AMapSearchAPI *_search;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //初始化检索对象
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;

    [self addMapView];
    [self addScaleButton];
    [self addLocationButton];

}

- (void)addMapView {
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _mapView.delegate = self;
    _mapView.showsCompass = NO;
    _mapView.scaleOrigin = CGPointMake(SCREEN_WIDTH - 150, SCREEN_HEIGHT - 30);
    _mapView.showsUserLocation = YES;
    [_mapView setUserTrackingMode: MAUserTrackingModeFollowWithHeading animated:YES];

    [self.view addSubview:_mapView];
}

- (void)addScaleButton {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-60, SCREEN_HEIGHT-200, 40, 80)];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.cornerRadius = 5.0;
    view.layer.masksToBounds = YES;
    view.layer.borderWidth = 0.5;
    view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(5, CGRectGetHeight(view.frame)/2.0, CGRectGetWidth(view.frame)-10, 0.5);
    layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    [view.layer addSublayer:layer];
    [self.view addSubview:view];

    UIButton *enlargeScaleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    enlargeScaleButton.frame = CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)/2);
    [enlargeScaleButton setTitle:@"+" forState:UIControlStateNormal];
    enlargeScaleButton.titleLabel.font = [UIFont systemFontOfSize:25];
    [enlargeScaleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [enlargeScaleButton setBackgroundImage:[ImageUtilities createImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
    [enlargeScaleButton addTarget:self action:@selector(scaleZoom:) forControlEvents:UIControlEventTouchUpInside];
    enlargeScaleButton.tag = 101;
    [view addSubview:enlargeScaleButton];

    UIButton *reduceScaleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    reduceScaleButton.frame = CGRectMake(0, CGRectGetHeight(view.frame)/2, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)/2);
    [reduceScaleButton setTitle:@"-" forState:UIControlStateNormal];
    reduceScaleButton.titleLabel.font = [UIFont systemFontOfSize:30];
    [reduceScaleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [reduceScaleButton setBackgroundImage:[ImageUtilities createImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
    [reduceScaleButton addTarget:self action:@selector(scaleZoom:) forControlEvents:UIControlEventTouchUpInside];
    reduceScaleButton.tag = 102;
    [view addSubview:reduceScaleButton];
}

- (void)addLocationButton {
    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    locationButton.frame = CGRectMake(20, SCREEN_HEIGHT-100, 40, 40);
    locationButton.backgroundColor = [UIColor whiteColor];
    locationButton.layer.cornerRadius = 5.0;
    locationButton.layer.masksToBounds = YES;
    locationButton.layer.borderWidth = 0.5;
    locationButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [locationButton setBackgroundImage:[ImageUtilities createImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
    [locationButton setTitle:@"◉" forState:UIControlStateNormal];
    [locationButton setTitleColor:RGB(40, 140, 230) forState:UIControlStateNormal];
    locationButton.titleLabel.font = [UIFont systemFontOfSize:30];
    [locationButton addTarget:self action:@selector(locationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:locationButton];
}

- (void)scaleZoom:(UIButton *)btn {
    CGFloat zoomLevel = _mapView.zoomLevel;
    switch (btn.tag) {
        case 101:
        {
            zoomLevel = fminf(zoomLevel+1, 19);
            [_mapView setZoomLevel:zoomLevel animated:YES];
        }
            break;

        case 102:
        {
            zoomLevel = fmaxf(zoomLevel-1, 3);
            [_mapView setZoomLevel:zoomLevel animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)locationButtonClicked:(UIButton *)btn {
    if (_currentCoordiate.latitude > 0) {
        CLLocationCoordinate2D myCoordinate = _currentCoordiate;
        MACoordinateRegion theRegion = MACoordinateRegionMake(myCoordinate, MACoordinateSpanMake(0.2, 0.2));
        [_mapView setScrollEnabled:YES];
        [_mapView setRegion:theRegion animated:YES];
        [_mapView setZoomLevel:16.1 animated:NO];
    }
}

-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    if(updatingLocation)
    {
        //取出当前位置的坐标
        NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
        _currentCoordiate = userLocation.coordinate;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
}

@end
