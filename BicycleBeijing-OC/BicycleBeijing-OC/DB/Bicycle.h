//
//  BicycleModel.h
//  BicycleTest
//
//  Created by XiaoYiPeng on 16/7/21.
//  Copyright © 2016年 XiaoYiPeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bicycle : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *localCode;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, assign) float longitude;
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) NSInteger num;
@property (nonatomic, copy) NSString *quyu;

@end
