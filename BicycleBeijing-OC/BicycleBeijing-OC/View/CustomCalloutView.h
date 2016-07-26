//
//  CustomCalloutView.h
//  iOS_3D_ClusterAnnotation
//
//  Created by PC on 15/7/9.
//  Copyright (c) 2015年 FENGSHENG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapSearchKit/AMapCommonObj.h>

@class CustomCalloutView;

@protocol CustomCalloutViewTapDelegate <NSObject>

@optional
/**
 *  选中某一行
 *
 *  @param calloutView calloutVeiw
 *  @param index       选中行号
 */
- (void)customCalloutView:(CustomCalloutView *)calloutView didDetailButtonTapped:(NSInteger)index;
/**
 *  弹出时调用
 *
 *  @param calloutView
 *  @param calloutViewFrame 要弹出的frame
 */
- (void)customCalloutView:(CustomCalloutView *)calloutView willChangeFrame:(CGRect)calloutViewFrame;

@end



@interface CustomCalloutView : UIView<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *poiArray;
@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, weak) id<CustomCalloutViewTapDelegate> delegate;

- (void)dismissCalloutView;

@end
