//
//  ChartMessage.m
//  Xmpp demo
//
//  Created by maomao on 15/7/21.
//  Copyright (c) 2015年 maomao. All rights reserved.
//

#import "ChartMessage.h"

@implementation ChartMessage

-(void)setDict:(NSDictionary *)dict
{
    _dict=dict;
    
    self.icon=dict[@"icon"];
    //    self.time=dict[@"time"];
    self.content=dict[@"content"];
    self.messageType=[dict[@"type"] intValue];
   
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}
@end
