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
#import "CoordinateQuadTree.h"
#import "CustomCalloutView.h"
#import "ClusterAnnotationView.h"
#import "ClusterAnnotation.h"

#define kCalloutViewMargin -12

@interface ViewController ()<MAMapViewDelegate, AMapSearchDelegate>
{
    //当前位置
    CLLocationCoordinate2D _currentCoordiate;
    AMapSearchAPI *_search;
}

/**
 *  地图
 */
@property (nonatomic, strong) MAMapView *mapView;
/**
 *  四叉权
 */
@property (nonatomic, strong) CoordinateQuadTree* coordinateQuadTree;
/**
 *  自定义的calloutView
 */
@property (nonatomic, strong) CustomCalloutView *customCalloutView;
/**
 *  当前选中的POI
 */
@property (nonatomic, strong) NSMutableArray *selectedPoiArray;
/**
 *
 */
@property (nonatomic, assign) BOOL shouldRegionChangeReCalculate;

@end

@implementation ViewController

/* 更新annotation. */
- (void)updateMapViewAnnotationsWithAnnotations:(NSArray *)annotations
{
    /* 用户滑动时，保留仍然可用的标注，去除屏幕外标注，添加新增区域的标注 */
    NSMutableSet *before = [NSMutableSet setWithArray:self.mapView.annotations];
    [before removeObject:[self.mapView userLocation]];
    NSSet *after = [NSSet setWithArray:annotations];

    /* 保留仍然位于屏幕内的annotation. */
    NSMutableSet *toKeep = [NSMutableSet setWithSet:before];
    [toKeep intersectSet:after];

    /* 需要添加的annotation. */
    NSMutableSet *toAdd = [NSMutableSet setWithSet:after];
    [toAdd minusSet:toKeep];

    /* 删除位于屏幕外的annotation. */
    NSMutableSet *toRemove = [NSMutableSet setWithSet:before];
    [toRemove minusSet:after];

    /* 更新. */
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView addAnnotations:[toAdd allObjects]];
        [self.mapView removeAnnotations:[toRemove allObjects]];
    });
}

- (void)addAnnotationsToMapView:(MAMapView *)mapView
{
    @synchronized(self)
    {
        if (self.coordinateQuadTree.root == nil || !self.shouldRegionChangeReCalculate)
        {
            NSLog(@"tree is not ready.");
            return;
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            /* 根据当前zoomLevel和zoomScale 进行annotation聚合. */
            double zoomScale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;

            NSArray *annotations = [self.coordinateQuadTree clusteredAnnotationsWithinMapRect:mapView.visibleMapRect
                                                                                withZoomScale:zoomScale
                                                                                 andZoomLevel:mapView.zoomLevel];
            /* 更新annotation. */
            [self updateMapViewAnnotationsWithAnnotations:annotations];
        });
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

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    DLog(@"地带变化");
    [self addAnnotationsToMapView:self.mapView];
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[ClusterAnnotation class]])
    {
        /* dequeue重用annotationView. */
        static NSString *const AnnotatioViewReuseID = @"AnnotatioViewReuseID";

        ClusterAnnotationView *annotationView = (ClusterAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotatioViewReuseID];

        if (!annotationView)
        {
            annotationView = [[ClusterAnnotationView alloc] initWithAnnotation:annotation
                                                               reuseIdentifier:AnnotatioViewReuseID];
        }

        /* 设置annotationView的属性. */
        annotationView.annotation = annotation;
        annotationView.count = [(ClusterAnnotation *)annotation count];
        /* 不弹出原生annotation */
        annotationView.canShowCallout = NO;

        return annotationView;
    }

    return nil;
}

- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view
{
    [view setNeedsDisplay];
    [self.selectedPoiArray removeAllObjects];
    [self.customCalloutView dismissCalloutView];
    self.customCalloutView.delegate = nil;
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    if (![view isMemberOfClass:[ClusterAnnotationView class]]) {
        return;
    }
    [view setNeedsDisplay];
    ClusterAnnotation *annotation = (ClusterAnnotation *)view.annotation;
    for (AMapPOI *poi in annotation.pois)
    {
        [self.selectedPoiArray addObject:poi];
    }

    [self.mapView setCenterCoordinate:view.annotation.coordinate animated:YES];
//    [self.customCalloutView setPoiArray:self.selectedPoiArray];
//    self.customCalloutView.delegate = self;

    // 调整位置
    self.customCalloutView.center = CGPointMake(CGRectGetMidX(view.bounds), -CGRectGetMidY(self.customCalloutView.bounds) - CGRectGetMidY(view.bounds) - kCalloutViewMargin);

    [view addSubview:self.customCalloutView];
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

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    //初始化检索对象
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    self.coordinateQuadTree = [[CoordinateQuadTree alloc] init];
    self.selectedPoiArray = [[NSMutableArray alloc] init];
    self.customCalloutView = [[CustomCalloutView alloc] init];

    [self addMapView];
    [self addScaleButton];
    [self addLocationButton];
    [self addAnnotation];
}

- (void)viewDidAppear:(BOOL)animated {
    
}

/**
 *  添加地图
 */
- (void)addMapView {
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.mapView.delegate = self;
    self.mapView.showsCompass = NO;
    self.mapView.scaleOrigin = CGPointMake(SCREEN_WIDTH - 150, SCREEN_HEIGHT - 30);
    self.mapView.showsUserLocation = YES;
    [self.mapView setUserTrackingMode: MAUserTrackingModeFollow animated:YES];

    [self.view addSubview:self.mapView];
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

    self.shouldRegionChangeReCalculate = NO;

    // 清理
    [self.selectedPoiArray removeAllObjects];
    [self.customCalloutView dismissCalloutView];
    [self.mapView removeAnnotations:self.mapView.annotations];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        /* 建立四叉树. */
        [self.coordinateQuadTree buildTreeWithPOIs:bicycles];
        self.shouldRegionChangeReCalculate = YES;
    });
}

@end
