//
//  DimensMacros.h
//  BicycleBeijing-OC
//
//  Created by XiaoYiPeng on 16/7/19.
//  Copyright © 2016年 XiaoYiPeng. All rights reserved.
//

#ifndef DimensMacros_h
#define DimensMacros_h

//状态栏高度
#define STATUS_BAR_HEIGHT 20
//NavBar高度
#define NAVIGATION_BAR_HEIGHT 44
//状态栏 ＋ 导航栏 高度
#define STATUS_AND_NAVIGATION_HEIGHT ((STATUS_BAR_HEIGHT) + (NAVIGATION_BAR_HEIGHT))

//屏幕 rect
#define SCREEN_RECT ([UIScreen mainScreen].bounds)

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define CONTENT_HEIGHT (SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT)

//屏幕分辨率
#define SCREEN_RESOLUTION (SCREEN_WIDTH * SCREEN_HEIGHT * ([UIScreen mainScreen].scale))

#define Rate_X(X) X/375.00*SCREEN_WIDTH  //X比例 设计图宽 为 750时
#define Rate_Y(Y) Y/667.00*SCREEN_HEIGHT  //Y比例 设计图高 为 1334时
#define Rate_W(W) W/375.00*SCREEN_WIDTH  //W比例 设计图宽 为 750时
#define Rate_H(H) H/667.00*SCREEN_HEIGHT  //H比例 设计图高 为 1334时



#endif /* DimensMacros_h */
