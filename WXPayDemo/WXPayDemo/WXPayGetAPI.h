//
//  WXPayGetAPI.h
//  WXPayDemo
//
//  Created by yifutong on 2018/12/14.
//  Copyright © 2018年 yifutong. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol WXPayGetAPIDelegate <NSObject>
@required //强制方法列表
- (void)getResponseData:(NSDictionary *) dict;
@end

@interface WXPayGetAPI : NSObject
@property (nonatomic, strong) NSMutableData *responseData;
@property(nonatomic,weak) id<WXPayGetAPIDelegate> delegate;
- (void)getWXAPPInfo:(NSDictionary *) positioning;
@end
