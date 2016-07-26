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

//定位按钮初始位置
#define LoactionButtonFrame CGRectMake(20, SCREEN_HEIGHT-100, 40, 40)

@interface ViewController ()<MAMapViewDelegate, AMapSearchDelegate, CustomCalloutViewTapDelegate>
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
 *  定位按钮
 */
@property (nonatomic, strong) UIButton *locationButton;
/**
 *  缩放按钮的view
 */
@property (nonatomic, strong) UIView *scaleView;
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
 *  当前选中的标注
 */
@property (nonatomic, strong) ClusterAnnotation *selectedAnnotation;
/**
 *
 */
@property (nonatomic, assign) BOOL shouldRegionChangeReCalculate;
/**
 *  等地图变化完毕需要选中的的网点
 */
@property (nonatomic, assign) Bicycle *needSelectedBicycle;

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
        /**
         *  有时候添加完了标注的view后，有的要选中
         */
        if (self.needSelectedBicycle) {
            for (ClusterAnnotation *annotation in toAdd) {
                if (annotation.coordinate.longitude == self.needSelectedBicycle.longitude &&
                    annotation.coordinate.latitude == self.needSelectedBicycle.latitude) {
                    [self.mapView selectAnnotation:annotation animated:YES];
                    self.needSelectedBicycle = nil;
                }
            }
            if (self.needSelectedBicycle!=nil) {
                //如果没找到要先中的自行车网点，说明放的还不够大，继续放大
                CGFloat currentLevel = self.mapView.zoomLevel;
                if (currentLevel<19.0) {
                    CGFloat toLevel = fmin(currentLevel+1.0, self.mapView.maxZoomLevel);
                    [self.mapView setZoomLevel:toLevel animated:YES];
                }
            }
        }
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
        [_mapView setZoomLevel:16.1 animated:YES];
    }
}

- (void)dismissCalloutView:(UIButton *)btn {
    [self.mapView deselectAnnotation:self.selectedAnnotation animated:YES];
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
    self.selectedAnnotation = nil;
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
    self.selectedAnnotation = annotation;
    for (AMapPOI *poi in annotation.pois)
    {
        [self.selectedPoiArray addObject:poi];
    }
//    [self.mapView setCenterCoordinate:view.annotation.coordinate animated:YES];
    self.customCalloutView.delegate = self;
    [self.customCalloutView setPoiArray:self.selectedPoiArray];

    [self.view addSubview:self.customCalloutView];
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

#pragma mark - CustomCalloutViewTapDelegate
//点击了网点列表上的一行
- (void)customCalloutView:(CustomCalloutView *)calloutView didDetailButtonTapped:(NSInteger)index {
    Bicycle *bicycle = self.selectedPoiArray[index];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(bicycle.latitude, bicycle.longitude);
    [self.customCalloutView dismissCalloutView];
    [self.mapView setCenterCoordinate:coordinate animated:YES];
    [self.mapView setZoomLevel:16.1 animated:YES];
    //设置要选中的网点，等放大完成后会选中
    self.needSelectedBicycle = bicycle;
}
//calloutview要弹出时会调用
- (void)customCalloutView:(CustomCalloutView *)calloutView willChangeFrame:(CGRect)calloutViewFrame; {
    //判断缩放按钮是否被遮住
    BOOL scaleViewCoverd = CGRectGetMaxY(self.scaleView.frame)>calloutViewFrame.origin.y;
    if (scaleViewCoverd) {
        self.scaleView.alpha = 0.0;
    } else {
        self.scaleView.alpha = 1.0;
    }
    CGRect toRect = self.locationButton.frame;
    toRect.origin.y = calloutViewFrame.origin.y - self.locationButton.frame.size.height - 10;
    if (toRect.origin.y<0) {
        self.locationButton.frame = LoactionButtonFrame;
    } else {
        self.locationButton.frame = toRect;
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
    [self.customCalloutView.backButton addTarget:self action:@selector(dismissCalloutView:) forControlEvents:UIControlEventTouchUpInside];
    self.customCalloutView.delegate = self;

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
    self.scaleView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-60, SCREEN_HEIGHT-200, 40, 80)];
    self.scaleView.backgroundColor = [UIColor whiteColor];
    self.scaleView.layer.cornerRadius = 5.0;
    self.scaleView.layer.masksToBounds = YES;
    self.scaleView.layer.borderWidth = 0.5;
    self.scaleView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(5, CGRectGetHeight(self.scaleView.frame)/2.0, CGRectGetWidth(self.scaleView.frame)-10, 0.5);
    layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.scaleView.layer addSublayer:layer];
    [self.view addSubview:self.scaleView];

    UIButton *enlargeScaleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    enlargeScaleButton.frame = CGRectMake(0, 0, CGRectGetWidth(self.scaleView.frame), CGRectGetHeight(self.scaleView.frame)/2);
    [enlargeScaleButton setTitle:@"+" forState:UIControlStateNormal];
    enlargeScaleButton.titleLabel.font = [UIFont systemFontOfSize:25];
    [enlargeScaleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [enlargeScaleButton setBackgroundImage:[ImageUtilities createImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
    [enlargeScaleButton addTarget:self action:@selector(scaleZoom:) forControlEvents:UIControlEventTouchUpInside];
    enlargeScaleButton.tag = 101;
    [self.scaleView addSubview:enlargeScaleButton];

    UIButton *reduceScaleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    reduceScaleButton.frame = CGRectMake(0, CGRectGetHeight(self.scaleView.frame)/2, CGRectGetWidth(self.scaleView.frame), CGRectGetHeight(self.scaleView.frame)/2);
    [reduceScaleButton setTitle:@"-" forState:UIControlStateNormal];
    reduceScaleButton.titleLabel.font = [UIFont systemFontOfSize:30];
    [reduceScaleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [reduceScaleButton setBackgroundImage:[ImageUtilities createImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
    [reduceScaleButton addTarget:self action:@selector(scaleZoom:) forControlEvents:UIControlEventTouchUpInside];
    reduceScaleButton.tag = 102;
    [self.scaleView addSubview:reduceScaleButton];
}

/**
 *  添加到定位位置按钮
 */
- (void)addLocationButton {
    self.locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.locationButton.frame = LoactionButtonFrame;
    self.locationButton.backgroundColor = [UIColor whiteColor];
    self.locationButton.layer.cornerRadius = 5.0;
    self.locationButton.layer.masksToBounds = YES;
    self.locationButton.layer.borderWidth = 0.5;
    self.locationButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.locationButton setBackgroundImage:[ImageUtilities createImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
    [self.locationButton setTitle:@"◉" forState:UIControlStateNormal];
    [self.locationButton setTitleColor:RGB(40, 140, 230) forState:UIControlStateNormal];
    self.locationButton.titleLabel.font = [UIFont systemFontOfSize:30];
    [self.locationButton addTarget:self action:@selector(locationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.locationButton];
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
