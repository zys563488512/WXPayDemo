//
//  WXPayGetAPI.m
//  WXPayDemo
//
//  Created by yifutong on 2018/12/14.
//  Copyright © 2018年 yifutong. All rights reserved.
//

#import "WXPayGetAPI.h"
#import <CommonCrypto/CommonDigest.h>

#define createWcOrder @"https://alipay.3c-buy.com/api/createWcOrder"
#define key @"gNociwieX1aCSkhvVemcXkaF9KVmkXm8"
@implementation WXPayGetAPI

//处理assToken
- (void)getWXAPPInfo:(NSDictionary *)positioning{
    NSDictionary * dict = @{@"location":positioning};
    NSString * str = [self convertToJsonData:dict];
    [self delegateTest:str];
}
-(NSMutableData *)responseData
{
    if (_responseData == nil) {
        _responseData = [NSMutableData data];
    }
    return _responseData;
}


 //发送请求，代理方法
-(void)delegateTest:(NSString *)baseString
 {
     NSDictionary * ndict = @{@"merchantOutOrderNo":[self getNowTimeTimestamp3],@"merid":@"yft2017082500005",@"orderMoney":@"100",@"orderTime":@"20180516150037",@"noncestr":@"1234",@"notifyUrl":@"http://jhpay.chinambpc.com/"};
     
     NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:ndict];
     NSArray *keyArray = [dict allKeys];
     NSArray *sortArray = [keyArray sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
         return [obj1 compare: obj2 options:NSNumericSearch];
     }];//对key进行遍历排序
     NSMutableArray *valueArray = [NSMutableArray array];
     for (NSString *sortString in sortArray) {
        [valueArray addObject:[dict objectForKey: sortString]];
     } //对排序后的key取value
     NSMutableArray *signArray = [NSMutableArray array];
     for (int i =0; i < sortArray.count; i++) {
         NSString *keyValueStr = [NSString stringWithFormat:@"%@=%@",sortArray[i],valueArray[i]];
         [signArray addObject: keyValueStr];
     }    //输出新的数组   key=value
     NSString *sign = [signArray componentsJoinedByString:@"&"];
     NSString * signStr = [NSString stringWithFormat:@"%@&key=%@",sign,key];
     NSString * token = [self md5:signStr];
     NSLog(@"token == %@",token);
     NSString * sign1 = [NSString stringWithFormat:@"%@&address=%@&sign=%@",sign,baseString,token];
     //第一步，创建url
     NSURL *url = [NSURL URLWithString:createWcOrder];
     //第二步，创建请求
     NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
     [request setHTTPMethod:@"POST"];
//     NSString *str = @"merchantOutOrderNo=201710231535456885&merid=yft2017082500005&noncestr=12345678910&notifyUrl=http://jhpay.chinambpc.com/api/callback&orderMoney=1.00&orderTime=20171023153545&sign=4087bd0f 3476970729c75ee28a8f623c&id=张三&address=4087bd0f3476970729c75ee28a8f62";
     NSData *data = [sign1 dataUsingEncoding:NSUTF8StringEncoding];
     [request setHTTPBody:data];
     //第三步，连接服务器
     NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
     
}
-(NSString *)convertToJsonData:(NSDictionary *)dict

{
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
    
}
//接收到服务器回应的时候调用此方法
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    NSLog(@"%@",[res allHeaderFields]);
    self.responseData = [NSMutableData data];
    
}
//接收到服务器传输数据的时候调用，此方法根据数据大小执行若干次
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}
//数据传完之后调用此方法
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:nil];
    [_delegate getResponseData:dict];
}
//网络请求过程中，出现任何错误（断网，连接超时等）会进入此方法
-(void)connection:(NSURLConnection *)connection
 didFailWithError:(NSError *)error
{
    NSLog(@"%@",[error localizedDescription]);
}

 //1.接收到服务器响应的时候调用该方法
 -(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
 {     //在该方法中可以得到响应头信息，即response
       NSLog(@"didReceiveResponse--%@",[NSThread currentThread]);
  
       //注意：需要使用completionHandler回调告诉系统应该如何处理服务器返回的数据
       //默认是取消的
       /*
            NSURLSessionResponseCancel = 0,        默认的处理方式，取消
            NSURLSessionResponseAllow = 1,         接收服务器返回的数据
            NSURLSessionResponseBecomeDownload = 2,变成一个下载请求
            NSURLSessionResponseBecomeStream        变成一个流
         */
  
       completionHandler(NSURLSessionResponseAllow);
   }

 //2.接收到服务器返回数据的时候会调用该方法，如果数据较大那么该方法可能会调用多次
 -(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
 {     NSLog(@"didReceiveData--%@",[NSThread currentThread]);
     
       //拼接服务器返回的数据
       [self.responseData appendData:data];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:nil];
     [_delegate getResponseData:dict];
   }

 //3.当请求完成(成功|失败)的时候会调用该方法，如果请求失败，则error有值
 -(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
 {     NSLog(@"didCompleteWithError--%@",[NSThread currentThread]);
  
       if(error == nil)
   {
        //解析数据,JSON解析请参考http://www.cnblogs.com/wendingding/p/3815303.html
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:nil];
        NSLog(@"%@",dict);
    }
}
//获取当前时间戳  （以毫秒为单位）

- (NSString *)getNowTimeTimestamp3{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SSS"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]*1000];
    
    return timeSp;
    
}
- (NSString*) md5:(NSString*) str
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), result );
    
    NSMutableString *hash = [NSMutableString string];
    for(int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
    {
        [hash appendFormat:@"%02X",result[i]];
    }
    return [hash lowercaseString];
}
@end
