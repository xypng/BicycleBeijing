//
//  DownloadOfflinMapViewController.m
//  BicycleBeijing-OC
//
//  Created by XiaoYiPeng on 16/7/28.
//  Copyright © 2016年 XiaoYiPeng. All rights reserved.
//  离线地图下载页面

#import "DownloadOfflinMapViewController.h"
#import "MAMapKit/MAMapKit.h"

@interface DownloadOfflinMapViewController ()

/**
 *  北京离线地图下载项
 */
@property (nonatomic, strong) MAOfflineItem *beijingOfflineItem;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

@end

@implementation DownloadOfflinMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"离线地图";
    self.view.backgroundColor = [UIColor lightGrayColor];

    NSArray *cities = [MAOfflineMap sharedOfflineMap].cities;
    for (MAOfflineItem *item in cities) {
        if ([item.name isEqualToString:@"北京市"]) {
            self.beijingOfflineItem = item;
            break;
        }
    }

    switch (self.beijingOfflineItem.itemStatus) {
        case MAOfflineItemStatusNone:
            //不存在
        {
            [self.downloadButton setTitle:@"下载" forState:UIControlStateNormal];
            [self.downloadButton setTitle:@"继续" forState:UIControlStateSelected];
            [self.downloadButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            self.downloadButton.layer.borderColor = [UIColor blueColor].CGColor;
            self.downloadButton.layer.borderWidth = 1.0;
        }
            break;
        case MAOfflineItemStatusCached:
            //缓存状态
        {
            [self.downloadButton setTitle:@"下载" forState:UIControlStateNormal];
            [self.downloadButton setTitle:@"继续" forState:UIControlStateSelected];
            [self.downloadButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            self.downloadButton.layer.borderColor = [UIColor blueColor].CGColor;
            self.downloadButton.layer.borderWidth = 1.0;
        }
            break;
        case MAOfflineItemStatusInstalled:
            //已安装
        {

        }
            break;
        case MAOfflineItemStatusExpired:
            //已过期
        {

        }
            break;

        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)downloadOfflineMap:(UIButton *)btn {
    if (self.beijingOfflineItem==nil || self.beijingOfflineItem.itemStatus == MAOfflineItemStatusInstalled) {
        return;
    }
    DLog(@"download=%@", self.beijingOfflineItem.name);
    [[MAOfflineMap sharedOfflineMap] downloadItem:self.beijingOfflineItem shouldContinueWhenAppEntersBackground:YES downloadBlock:^(MAOfflineItem *downloadItem, MAOfflineMapDownloadStatus downloadStatus, id info) {
        if (downloadStatus == MAOfflineMapDownloadStatusWaiting)
        {
            NSLog(@"状态为: %@", @"等待下载");
        }
        else if(downloadStatus == MAOfflineMapDownloadStatusStart)
        {
            NSLog(@"状态为: %@", @"开始下载");
        }
        else if(downloadStatus == MAOfflineMapDownloadStatusProgress)
        {
            NSLog(@"状态为: %@", @"正在下载");
        }
        else if(downloadStatus == MAOfflineMapDownloadStatusCancelled) {
            NSLog(@"状态为: %@", @"取消下载");
        }
        else if(downloadStatus == MAOfflineMapDownloadStatusCompleted) {
            NSLog(@"状态为: %@", @"下载完成");
        }
        else if(downloadStatus == MAOfflineMapDownloadStatusUnzip) {
            NSLog(@"状态为: %@", @"下载完成，正在解压缩");
        }
        else if(downloadStatus == MAOfflineMapDownloadStatusError) {
            NSLog(@"状态为: %@", @"下载错误");
        }
        else if(downloadStatus == MAOfflineMapDownloadStatusFinished) {
            NSLog(@"状态为: %@", @"全部完成");
        }
    }];
}

/**
 *  返回按钮
 */
- (void)backButtonClick:(UIButton *)btn {
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

@end
