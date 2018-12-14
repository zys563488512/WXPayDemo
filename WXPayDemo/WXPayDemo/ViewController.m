//
//  ViewController.m
//  WXPayDemo
//
//  Created by yifutong on 2018/12/14.
//  Copyright © 2018年 yifutong. All rights reserved.
//

#import "ViewController.h"
#import "WXPayGetAPI.h"
#import "WXApi.h"
#import <CoreLocation/CoreLocation.h>
@interface ViewController () <CLLocationManagerDelegate,WXPayGetAPIDelegate>
@property (nonatomic,strong) CLLocationManager *locationManager;//arc下定位记得使用强引
@property (nonatomic,strong) NSDictionary * positioning;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _positioning = [[NSDictionary alloc] init];
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(100, 100, 150, 30)];
    [button setTitle:@"唤醒微信小程序" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor blueColor]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [self getLocation];
    
}
- (void)btnClick{
    WXPayGetAPI * api = [[WXPayGetAPI alloc] init];
    api.delegate = self;
    [api getWXAPPInfo:self.positioning];
}
#pragma mark -- WXPayGetAPIDelegate
- (void)getResponseData:(NSDictionary *)dict {
    NSLog(@"dict === %@",dict);
    if ([self wXXCx:dict]) {
        NSLog(@"成功");
    }else {
        NSLog(@"失败");
    }
}
- (BOOL)wXXCx:(NSDictionary *)dict {
    WXLaunchMiniProgramReq *launchMiniProgramReq = [WXLaunchMiniProgramReq object];
    launchMiniProgramReq.userName = @"小程序username";  //拉起的小程序的username
    launchMiniProgramReq.path = @"要调起小程序页面路径";    //拉起小程序页面的可带参路径，不填默认拉起小程序首页
    launchMiniProgramReq.miniProgramType = WXMiniProgramTypeTest; //分享小程序的版本（正式，开发，体验）
    return [WXApi sendReq:launchMiniProgramReq];
}
//定位方法

- (void)getLocation
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //提示用户开启定位
        [_locationManager requestAlwaysAuthorization];
    }
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 5.0;
    
    //开启定位
    
    [_locationManager startUpdatingLocation];
}

//实现协议

#pragma mark - CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *newLocation = [locations lastObject];
    //使用当前坐标
    NSString * latitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
    NSString * longtitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
    self.positioning = @{@"latitude":latitude,@"longtitude":longtitude};
    //关闭定位
    [manager stopUpdatingLocation];
}

@end
