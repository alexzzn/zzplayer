//
//  CommonTools.h
//  MyPlayer
//
//  Created by ZZN on 2017/9/18.
//  Copyright © 2017年 ZZN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonTools : NSObject
    
    
+(void)UPLOAD:(NSString *)URLString parameters:(NSDictionary *)parameters filesDatas:(NSData *)filesDatas success:(void (^)(id))success failure:(void (^)(NSError *))failure;
+(NSInteger)timeSwitchTimestamp:(NSString *)formatTime andFormatter:(NSString *)format;
    
@end
