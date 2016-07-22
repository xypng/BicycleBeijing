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
#import "DataManager.h"
#import "Bicycle.h"

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
//    [self addAnnotation];
}

/**
 *  添加地图
 */
- (void)addMapView {
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _mapView.delegate = self;
    _mapView.showsCompass = NO;
    _mapView.scaleOrigin = CGPointMake(SCREEN_WIDTH - 150, SCREEN_HEIGHT - 30);
    _mapView.showsUserLocation = YES;
    [_mapView setUserTrackingMode: MAUserTrackingModeFollow animated:YES];

    [self.view addSubview:_mapView];
}

/**
 *  添加缩放按钮
 */
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

/**
 *  添加到定位位置按钮
 */
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

/**
 *  添加自行车网点标注
 */
- (void)addAnnotation {
    NSArray<Bicycle *> *bicycles = [DataManager getBicycles];
    for (Bicycle *bicycle in bicycles) {
        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
        pointAnnotation.coordinate = CLLocationCoordinate2DMake(bicycle.latitude, bicycle.longitude);
        pointAnnotation.title = bicycle.name;
        pointAnnotation.subtitle = bicycle.address;
        [_mapView addAnnotation:pointAnnotation];
    }
}


#pragma mark - 按钮事件
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


#pragma mark - MAMapViewDelegate
//定位成功返回
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    if(updatingLocation)
    {
        //取出当前位置的坐标
        DLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
        _currentCoordiate = userLocation.coordinate;
    }
}

//定位失败返回
- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    DLog(@"定位失败，请检查配置");
}

/**
 *  地图将要发生移动时调用此接口
*/
- (void)mapView:(MAMapView *)mapView mapWillMoveByUser:(BOOL)wasUserAction {
    DLog(@"地图将要移动");
}

/**
 *  地图移动结束后调用此接口
*/
- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction {
    DLog(@"地图结束移动");
}

/**
 *  地图将要发生缩放时调用此接口
 */
- (void)mapView:(MAMapView *)mapView mapWillZoomByUser:(BOOL)wasUserAction {
    DLog(@"地图将要缩放");
}

/**
 *  地图缩放结束后调用此接口
 */
- (void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction {
    DLog(@"地图结束缩放");
}

/**
 * @brief 地图开始加载
 */
- (void)mapViewWillStartLoadingMap:(MAMapView *)mapView {
    DLog(@"地图开始加载");
}

/**
 * @brief 地图加载成功
 */
- (void)mapViewDidFinishLoadingMap:(MAMapView *)mapView {
    DLog(@"地图加载成功");
}

//地图加载失败
- (void)mapViewDidFailLoadingMap:(MAMapView *)mapView withError:(NSError *)error
{
    DLog(@"地图加载失败");
}

#pragma mark - AMapSearchDelegate
//云图搜索回调
- (void)onCloudSearchDone:(AMapCloudSearchBaseRequest *)request response:(AMapCloudPOISearchResponse *)response
{
    if(response.POIs.count == 0)
    {
        return;
    }
    for (AMapCloudPOI *poi in response.POIs) {
        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
        pointAnnotation.coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
        pointAnnotation.title = poi.name;
        pointAnnotation.subtitle = poi.address;
        [_mapView addAnnotation:pointAnnotation];
    }

}

- (void)viewDidAppear:(BOOL)animated {
    
}

@end
