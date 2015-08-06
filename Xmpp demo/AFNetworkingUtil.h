//
//  AFNetworkingUtil.h
//  TopHold实盘
//
//  Created by tianhou on 15/5/8.
//  Copyright (c) 2015年 tianhou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AFNetworkingUtil : NSObject

//get json
+ (void)getJson:(NSString *)url
 withParameters:(NSDictionary *)parameters
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSError *error))failure;

//post json
+ (void)postJson:(NSString *)url
  withParameters:(NSDictionary *)parameters
         success:(void (^)(id responseObject))success
         failure:(void (^)(NSError *error))failure;



@end
