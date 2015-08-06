//
//  FriendController.h
//  Xmpp demo
//
//  Created by maomao on 15/7/17.
//  Copyright (c) 2015年 maomao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface FriendController : UIViewController<ChatDelegate>

@property (nonatomic,copy)NSString *Name;


@end
