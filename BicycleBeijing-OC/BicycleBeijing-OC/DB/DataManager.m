//
//  DataManager.m
//  BicycleTest
//
//  Created by XiaoYiPeng on 16/7/21.
//  Copyright © 2016年 XiaoYiPeng. All rights reserved.
//

#import "DataManager.h"
#import "FMDB.h"
#import "Bicycle.h"

@implementation DataManager

+ (NSArray<Bicycle *> *)getBicycles {
    NSMutableArray<Bicycle *> *returnArray = [NSMutableArray<Bicycle *> array];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"beijingbicycle" ofType:@"sqlite"];
    FMDatabase *dataBase = [FMDatabase databaseWithPath:filePath];
    if ([dataBase open]) {
        NSLog(@"database open");
    } else {
        return returnArray;
    }
    FMResultSet *rs = [dataBase executeQuery:@"select * from t_bicycle"];
    while ([rs next]) {
        Bicycle *bicycle = [[Bicycle alloc] init];
        bicycle.name = [rs stringForColumn:@"name"];
        bicycle.code = [rs stringForColumn:@"code"];
        bicycle.localCode = [rs stringForColumn:@"localCode"];
        bicycle.address = [rs stringForColumn:@"address"];
        bicycle.longitude = [rs doubleForColumn:@"lon"];
        bicycle.latitude = [rs doubleForColumn:@"lat"];
        bicycle.num = [rs intForColumn:@"num"];
        bicycle.quyu = [rs stringForColumn:@"quyu"];
        [returnArray addObject:bicycle];
    }
    [dataBase close];
    return returnArray;
}

@end
