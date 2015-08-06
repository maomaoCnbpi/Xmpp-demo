//
//  ChartMessage.h
//  Xmpp demo
//
//  Created by maomao on 15/7/21.
//  Copyright (c) 2015年 maomao. All rights reserved.
//

typedef enum {
    
    kMessageFrom=0,
    kMessageTo
  
    
}ChartMessageType;
#import <Foundation/Foundation.h>

@interface ChartMessage : NSObject
@property (nonatomic,assign) ChartMessageType messageType;
@property (nonatomic, copy) NSString *icon;
//@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSDictionary *dict;
@property (nonatomic,copy) UIImage *image;

@end