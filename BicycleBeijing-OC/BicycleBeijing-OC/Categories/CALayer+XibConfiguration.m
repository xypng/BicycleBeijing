//
//  CALayer+XibConfiguration.m
//  HHY
//
//  Created by jisn on 16/6/15.
//  Copyright © 2016年 tiansha. All rights reserved.
//

#import "CALayer+XibConfiguration.h"

@implementation CALayer (XibConfiguration)
-(void)setBorderUIColor:(UIColor*)color
{
    self.borderColor = color.CGColor;
}
@end
