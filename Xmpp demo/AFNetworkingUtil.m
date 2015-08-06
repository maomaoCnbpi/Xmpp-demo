//
//  AFNetworkingUtil.m
//  TopHold实盘
//
//  Created by tianhou on 15/5/8.
//  Copyright (c) 2015年 tianhou. All rights reserved.
//

#import "AFNetworkingUtil.h"
#import "AFHTTPRequestOperationManager.h"


@implementation AFNetworkingUtil

//get json
+ (void)getJson:(NSString *)url
 withParameters:(NSDictionary *)parameters
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //设置超时时间(秒)
    manager.requestSerializer.timeoutInterval = 30;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];//application/json text/html
    [manager GET:url parameters: parameters
         success:^(AFHTTPRequestOperation *operation,id responseObject) {
             if (responseObject) {
                 success(responseObject);
             } else {
                 failure(nil);
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             failure(error);
         }
     ];
}

//post json
+ (void)postJson:(NSString *)url
  withParameters:(NSDictionary *)parameters
         success:(void (^)(id responseObject))success
         failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //设置超时时间(秒)
    manager.requestSerializer.timeoutInterval = 30;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:url parameters: parameters
          success:^(AFHTTPRequestOperation *operation,id responseObject) {
              if (responseObject) {
                  success(responseObject);
              } else {
                  failure(nil);
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              failure(error);
          }
     ];
}


@end
