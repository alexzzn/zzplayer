//
//  CommonTools.m
//  MyPlayer
//
//  Created by ZZN on 2017/9/18.
//  Copyright © 2017年 ZZN. All rights reserved.
//

#import "CommonTools.h"
#import <AFNetworking/AFNetworking.h>

@implementation CommonTools
    
    
    //上传 图片
+(void)UPLOAD:(NSString *)URLString parameters:(NSDictionary *)parameters filesDatas:(NSData *)filesDatas success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    
    if (URLString == nil && failure != nil) {
        failure([[NSError alloc] initWithDomain:NSCocoaErrorDomain code:0 userInfo:@{@"mag":@"url为空"}]);
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:parameters];
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"html/json",@"text/plain", nil];
    AFJSONResponseSerializer *jsonReponseSerializer = [AFJSONResponseSerializer serializer];
    // This will make the AFJSONResponseSerializer accept any content type
    jsonReponseSerializer.acceptableContentTypes = nil;
    manager.responseSerializer = jsonReponseSerializer;
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [manager POST:URLString parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData)
     {
         
         [formData appendPartWithFileData:filesDatas
                                     name:@"avatar"
                                 fileName:@"avatar"
                                 mimeType:@"image/png"];
         
     } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         
//         NSLog(@"%@", responseObject);
         
         if (success != nil) {
             success(responseObject);
         }

     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//         NSLog(@"%@", error);
         
         if (failure != nil) {
             failure(error);
         }
     }];
    
}
    


#pragma mark - 将某个时间转化成 时间戳

+(NSInteger)timeSwitchTimestamp:(NSString *)formatTime andFormatter:(NSString *)format{
    
    
    
    if (formatTime == nil) {
        
        return 0;
    }
    
    if (format == nil) {
        format = @"YYYY-MM-dd hh:mm:ss";
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    
    
    [formatter setDateFormat:format]; //(@"YYYY-MM-dd hh:mm:ss") ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    
    [formatter setTimeZone:timeZone];
    
    
    
    NSDate* date = [formatter dateFromString:formatTime]; //------------将字符串按formatter转成nsdate
    
    //时间转时间戳的方法:
    
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];
    
    
    
    NSLog(@"将某个时间转化成 时间戳&&&&&&&timeSp:%ld",(long)timeSp); //时间戳的值
    
    
    
    return timeSp;
    
}
    
@end
